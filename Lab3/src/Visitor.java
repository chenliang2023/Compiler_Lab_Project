import Scope.Scope;
import org.antlr.v4.runtime.*;
import LexerAndParser.*;
import Type.*;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

import java.util.ArrayList;
import java.util.List;

public class Visitor extends SysYParserBaseVisitor<Void> {
    //存储以下的数据：错误信息表，是否含有错误信息
    private List<String> errMsg = new ArrayList<>();
    private Scope globalScope = null;
    private Scope curScope = null;
    //如果全局作用域和局部作用域冲突，采取局部作用域的对应类型
    private boolean hasError = false;

    public List<String> getErrMsg() {
        return errMsg;
    }

    public boolean hasError() {
        return hasError;
    }

    private void addError(int typeNo, int lineNo) {
        errMsg.add("Error type " + typeNo + " at Line " + lineNo);
        hasError = true;
    }

    private int toDecimal(String Text){
        //便于存储数组使用
        if (Text.startsWith("0X") || Text.startsWith("0x")){
            return Integer.parseInt(Text.substring(2),16);
        } else if (Text.startsWith("0")){
            return Integer.parseInt(Text,2);
        } else {
            return Integer.parseInt(Text);
        }
    }
    
    @Override
    public Void visit(ParseTree tree) {
        return super.visit(tree);
    }

    //    @Override
    //    public Void visitTerminal(TerminalNode node){
    //        //处理终结符节点
    //        Token token = node.getSymbol();
    //        int ruleNum = token.getType() - 1;
    //        //获得对应的元素名
    //        String ruleName = SysYLexer.ruleNames[ruleNum];
    //        //获得对应的变量符号
    //        String tokenText = token.getText();
    //        if (ruleName.equals("IDENT")) {
    //            //如果是变量
    //            int lineNo = token.getLine();
    //            if (curScope.resolve(tokenText) == null) {
    //                //变量未声明
    //                addError(1, lineNo);
    //            }
    //        }
    //        return super.visitTerminal(node);
    //    }

    @Override
    public Void visitProgram(SysYParser.ProgramContext ctx) {
        //创建全局作用域：没有父作用域
        globalScope = new Scope(null);
        curScope = globalScope;
        Void re = super.visitProgram(ctx);
        //遍历结束后恢复作用域
        curScope = curScope.parent;
        return re;
    }

    //★：我们现在停留在这里，我想进行检查对应的函数是否存在问题，之后再补充其他的函数…………
    @Override
    public Void visitFuncDef(SysYParser.FuncDefContext ctx) {
        String funcName = ctx.IDENT().getText();
        //在全局定义域中查找对应的函数，看是否重复定义？
        if (globalScope.resolve(funcName) != null) {
            //说明重复定义了，还需要TODO:跳过对应的函数区
            addError(4,ctx.getStart().getLine());
            return null;
        }
        //否则需要添加新的定义表：只有是INT时，才是真正的函数
        Type retType = null;
        if (ctx.funcType().INT() != null) {
            retType = new BasicType();
        }
        //处理函数参数
        ArrayList<Type> params = new ArrayList<>();
        if (ctx.funcFParams() != null) {
            visit(ctx.funcFParams());
        }
        FunctionType functionType = new FunctionType(retType,params);
        //将类型添加到当前作用域中
        curScope.define(funcName, functionType);
        //进入函数作用域
        visit(ctx.block());
        return null;
    }
    //★：这里还需要加入对于形参的加入！！
    @Override
    public Void visitFuncFParam(SysYParser.FuncFParamContext ctx) {
        String varName = ctx.IDENT().getText();
        Type varType = new BasicType();//一定是INT类型
        //处理所有的数组维度
        if (ctx.funcArrayDims().L_BRACKT() != null) {
            //说明是数组
            SysYParser.FuncArrayDimsContext arrayDims = ctx.funcArrayDims();
            for (TerminalNode terminalNode : arrayDims.L_BRACKT()){
                //默认为0
                varType = new ArrayType(varType,0);
            }
        }
        if (!curScope.define(varName, varType)) {
            //包含的话就需要报错
            addError(3,ctx.getStart().getLine());
        }
        return null;
    }

    @Override
    public Void visitBlock(SysYParser.BlockContext ctx) {
        //访问块：添加新的作用域
        Scope newScope = new Scope(curScope);
        //添加作用域的形参
        newScope.addTypeList(curScope);
        curScope = newScope;
        ctx.blockItem().forEach(this::visit); // 依次visit block中的节点
        //切换回父级作用域
        curScope = curScope.parent;
        return null;
    }

    @Override
    public Void visitVarDecl(SysYParser.VarDeclContext ctx) {
        //访问变量的声明语句
        for (int i = 0; i < ctx.varDef().size(); i ++) {
            visit( ctx.varDef().get(i) );
        }
        return null;
    }

    @Override
    public Void visitVarDef(SysYParser.VarDefContext ctx) {
        String varName = ctx.IDENT().getText(); // c or d
        if (curScope.resolve(varName) != null) {
            //说明重复定义了
            addError(3,ctx.getStart().getLine());
            return null;
        }
        if (ctx.arrayDims() == null){
            //非数组
            if (ctx.ASSIGN() != null) {
                //包含定义的语句：即表达式的情况 和数组的情况（不可能）
                if (ctx.initVal().exp() != null) {
                    Type initialType = getExpType(ctx.initVal().exp());
                    if (!(initialType instanceof BasicType)) {
                        //不是基本类型：类型不匹配
                        addError(5,ctx.getStart().getLine());
                        return null;
                    }
                }
            }
            //如果说都没有问题的话，就添加上去
            curScope.define(varName, new BasicType());
        }
        else{
            //数组：递归表示
            Type contained = new BasicType();
            for (SysYParser.ConstExpContext context : ctx.arrayDims().constExp()){
                int elementCount = toDecimal(context.getText());
                contained = new ArrayType(contained, elementCount);
            }
            //不用检查右值！！！
            curScope.define(varName, contained);
        }
        return null;
    }

    @Override
    public Void visitConstDecl(SysYParser.ConstDeclContext ctx) {
        //访问常量的定义
        for (int i = 0; i < ctx.constDef().size(); i ++) {
            visit(ctx.constDef(i));
        }
        return null;
    }

    @Override
    public Void visitConstDef(SysYParser.ConstDefContext ctx) {
        String constName = ctx.IDENT().getText();
        if (curScope.resolve(constName) != null) {
            addError(3,ctx.getStart().getLine());
            return null;
        }
        if (ctx.arrayDims() == null){
            if (ctx.ASSIGN() != null) {
                if (ctx.constInitVal().constExp() != null) {
                    Type constInitType = getExpType(ctx.constInitVal().constExp().exp());
                    if (!(constInitType instanceof BasicType)) {
                        addError(5,ctx.getStart().getLine());
                    }
                }
            }
            curScope.define(constName, new BasicType());
        }else {
            //数组表示
            Type contained = new BasicType();
            for (SysYParser.ConstExpContext context : ctx.arrayDims().constExp()){
                int elementCount = toDecimal(context.getText());
                contained = new ArrayType(contained, elementCount);
            }
            curScope.define(constName, contained);
        }
        return null;
    }

    private Type getExpType(SysYParser.ExpContext ctx) {
        //判断表达式的类型=>函数类型
        if (ctx.IDENT() != null) {
            //之后判断函数是否存在，如果不存在
            String funcName = ctx.IDENT().getText();
            Type ifFuncType = curScope.resolve(funcName);
            if (ifFuncType instanceof FunctionType) {
                //说明函数存在,接下来检查参数是否正确
                ArrayList<Type> xParams = ((FunctionType) ifFuncType).getParamsType();
                ArrayList<Type> sParams = new ArrayList<>();
                for (SysYParser.ParamContext paramContext : ctx.funcRParams().param()){
                    sParams.add(getExpType(paramContext.exp()));
                }
                if (!sParams.equals(xParams)) {
                    //实参形参不一致
                    addError(8,ctx.getStart().getLine());
                    return null;
                }else{
                    //返回返回类型
                    return ((FunctionType) ifFuncType).getRetTy();
                }
            } else{
                if(ifFuncType != null){
                    //说明是对变量使用函数调用符
                    addError(10, ctx.getStart().getLine());
                }else {
                    //函数名不存在，报错
                    addError(2, ctx.getStart().getLine());
                }
            }
        }
        else if (ctx.L_PAREN() != null || ctx.unaryOp() != null) {
            //去括号或者返回操作数的类型
            return getExpType(ctx.exp(0));
        }else if (ctx.number() != null) {
            return new BasicType();
        }else if (ctx.MUL() != null || ctx.DIV() != null || ctx.MOD() != null || ctx.MINUS() != null || ctx.PLUS() != null) {
            Type op1 = getExpType(ctx.exp(0));
            Type op2 = getExpType(ctx.exp(1));
            if (op1.toString().equals("int") && op2.toString().equals("int")) {
                return op1;
            }
        }else if (ctx.lVal() != null) {
            return getLValType(ctx.lVal());
        }
        return null;
    }

    private Type getLValType(SysYParser.LValContext ctx) {
        String varName = ctx.IDENT().getText();
        Type varType = curScope.resolve(varName);
        if (varType == null) {
            return null;
        }else {
            for (SysYParser.ExpContext ignored : ctx.exp()){
                //有几个括号就加即可
                if (varType instanceof ArrayType) {
                    varType = ((ArrayType) varType).getContained();
                }else {
                    return null;
                }
            }
        }
        return varType;
    }
    @Override
    public Void visitLVal(SysYParser.LValContext ctx) {
        String varName = ctx.IDENT().getText();
        if (curScope.resolve(varName) == null) {
            //使用了未声明的变量
            addError(1, ctx.getStart().getLine());
        }
        Type varType = curScope.resolve(varName);
        int arrayDims = ctx.L_BRACKT().size();
        for (int i = 0; i < arrayDims; i ++) {
            if (varType instanceof ArrayType) {
                //一层一层拨开
                varType = ((ArrayType) varType).getContained();
            }else{
                //否则就是出现了下标错误
                addError(9, ctx.getStart().getLine());
                break;
            }
        }
        return null;
    }

    @Override
    public Void visitStmt(SysYParser.StmtContext ctx) {
        if (ctx.assignStmt() != null) {
            //如果是赋值语句
            SysYParser.AssignStmtContext assignStmt = ctx.assignStmt();
            Type lValType = getLValType(assignStmt.lVal());
            Type rValType = getExpType(assignStmt.exp());
            if (lValType instanceof FunctionType) {
                addError(11,ctx.getStart().getLine());
            } else if (!(lValType == null) && !(rValType == null) && !lValType.toString().equals(rValType.toString())) {
                addError(5, ctx.getStart().getLine());
            }
        }
        else if (ctx.returnStmt() != null) {
            Type retType = new BasicType();
            SysYParser.ReturnStmtContext returnStmt = ctx.returnStmt();
            if (returnStmt.exp() != null) {
                retType = getExpType(returnStmt.exp());
            }
            //查找是否是来自函数作用域？？？？？

        }
    }
}
