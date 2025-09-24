import ASM.RiscVBackEnd;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import java.io.*;
import java.util.List;
import Error.*;
import LexerAndParser.*;
import org.bytedeco.javacpp.BytePointer;
import org.bytedeco.llvm.LLVM.LLVMModuleRef;
import visitor.llvmVisitor;

import static org.bytedeco.llvm.global.LLVM.LLVMDisposeMessage;
import static org.bytedeco.llvm.global.LLVM.LLVMPrintModuleToFile;

public class Main {
    public static void main(String[] args) throws IOException {
        if (args.length < 2) {
            System.err.println("Input path is required");
            return;
        }
        String source = args[0];
        String target = args[1];
        String IR = args[2];
        CharStream input = CharStreams.fromFileName(source);
        SysYLexer sysYLexer = new SysYLexer(input);
        SysYParser sysYParser = new SysYParser(new CommonTokenStream(sysYLexer));

        ParseTree tree = sysYParser.program();
        llvmVisitor visitor = new llvmVisitor();
        visitor.visit(tree);

        final BytePointer error = new BytePointer();
        if (LLVMPrintModuleToFile(visitor.module(), IR, error) != 0) {    // moudle 是你自定义的 LLVMModuleRef 对象
            LLVMDisposeMessage(error);
        }

        LLVMModuleRef moduleRef = visitor.module();
        RiscVBackEnd backend = new RiscVBackEnd();      // 创建我们的后端实例
        String assemblyCode = backend.generateAsm(moduleRef); // 生成汇编代码字符串

        try (PrintWriter out = new PrintWriter(new FileWriter(target))) {
            out.print(assemblyCode); // 用 print 而不是 println，因为 assemblyCode 已经包含了换行
            System.out.println("🎉 RISC-V assembly code written to: " + target);
        } catch (IOException e) {
            System.err.println("😭 Error writing assembly to file: " + target);
            e.printStackTrace();
        }
        System.out.println("✅ Compilation process finished.");
    }
    private static void Lexer(CharStream input) {
        SysYLexer sysYLexer = new SysYLexer(input);
        LexerErrorListener errorListener = new LexerErrorListener();
        sysYLexer.removeErrorListeners();
        sysYLexer.addErrorListener(errorListener);
        List<? extends  Token> myTokens = sysYLexer.getAllTokens();
        if (!errorListener.hasError()){
            String[] typeNames = SysYLexer.ruleNames;
            for (Token token : myTokens) {
                printSysYTokenInformation(token, typeNames);
            }
        }
    }
    private static void Parser(CharStream input) {
        SysYLexer sysYLexer = new SysYLexer(input);
        // 创建词法符号流
        CommonTokenStream tokens = new CommonTokenStream(sysYLexer);
        // 创建语法分析器
        SysYParser sysYParser = new SysYParser(tokens);
        // 移除默认的错误监听器，并添加自定义的错误监听器
        ParserErrorListener errorListener = new ParserErrorListener();
        sysYParser.removeErrorListeners();
        sysYParser.addErrorListener(errorListener);
        ParseTree tree = sysYParser.program();
    }
    private static void printSysYTokenInformation(Token token,String[] typeNames) {
        String text = token.getText();
        if (token.getType() == Token.EOF) {
            return;
        }else if(token.getType() == SysYLexer.INTEGER_CONST){
            if (text.startsWith("0x") || text.startsWith("0X")){
                //为16进制数
                text = String.valueOf(Integer.parseInt(text.substring(2), 16));
            }else if (text.startsWith("0")){
                text = String.valueOf(Integer.parseInt(text, 8));
            }
        }
        System.err.println(typeNames[token.getType() - 1] + " " + text + " at Line " + token.getLine() + ".");
    }
}

