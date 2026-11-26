# Compiler_Lab_Project

南京大学《编译原理》课程实验项目。用 ANTLR4 生成 SysY 语言的词法与语法分析器，基于 Java 实现，后续实验接入 LLVM 生成中间表示与目标代码。

四个实验目录 `Lab3` 到 `Lab6` 各自独立，每个目录都是一份可单独编译运行的项目，内容为上一阶段的累积。

## 实验内容

| 目录 | 阶段 | 入口与产出 |
|---|---|---|
| `Lab3` | 语义分析 | `src/Main.java` 读取 `.sysy` 源文件，遍历语法树做类型与作用域检查，向 stderr 输出错误信息 |
| `Lab4` | 中间代码生成 | `Main` 接收源文件与目标路径两个参数，通过 `llvmVisitor` 生成 LLVM IR 并写入文件 |
| `Lab5` | 目标代码生成 | `Main` 接收源文件、汇编输出路径、IR 输出路径三个参数，经 `RiscVBackEnd` 生成 RISC-V 汇编 |
| `Lab6` | 中间代码优化 | `Main` 接收源文件与 IR 输出路径，经 `IR_Optimization.Run` 输出优化后的 IR |

## 目录结构

```
.
├── .idea/                  IntelliJ IDEA 的 VCS 配置
├── Lab3/
│   ├── src/Main.java       语义分析入口
│   ├── src/Visitor.java    SysY 语义检查访问器
│   ├── gen/                ANTLR 生成的词法分析器
│   ├── tests/              测试用例
│   ├── Makefile            编译、运行、清理、提交的目标
│   ├── Makefile.git        学号与自动 commit 规则
│   ├── Code.txt            ANTLR 生成命令记录
│   └── submit.sh           打包提交脚本
├── Lab4/
│   ├── CompilerTests/      parser / semantic / code-gen 三组用例
│   └── ...                 结构同 Lab3
├── Lab5/
│   ├── ASMTEST/            RISC-V 汇编测试用例
│   └── ...                 结构同 Lab3
└── Lab6/
    ├── optimize/           优化测试用例
    └── ...                 结构同 Lab3
```

合计 111 个文件。

## 环境依赖

- JDK（`Makefile` 中 `javac -g` 编译，`java` 运行）
- ANTLR 4.9.1：`antlr-4.9.1-complete.jar`
- LLVM Java 绑定：`org.bytedeco.llvm`（Lab4 起使用，代码中通过 `org.bytedeco.javacpp` 调用）
- make 与 bash（`submit.sh`）

`Makefile` 默认按 Linux 路径查找依赖：

```make
export CLASSPATH=/usr/local/lib/antlr-*-complete.jar
ANTLRPATH = $(shell find /usr/local/lib -name "antlr-*-complete.jar")
```

在其他环境运行时，需要把 ANTLR jar 放到对应位置，或修改 `Makefile` 中的这两行。

## 编译与运行

进入某个实验目录后执行：

```bash
make compile      # 生成 ANTLR 解析器并编译 Java 源码到 classes/
make run FILEPATH=tests/test1.sysy
make test         # 以 test1.sysy 跑一遍
make clean        # 清理生成物
make submit       # 清理后打包，调用 submit.sh
```

`make compile` 依赖 `Makefile.git` 里的自动提交规则，会在编译前提交一次仓库状态。只想编译而不产生提交时，手动执行 Makefile 中的 `javac` 命令即可。

`Code.txt` 记录的是在本地生成 ANTLR 解析器的命令，例如：

```
java -jar .\lib\antlr-4.9.1-complete.jar -listener -visitor -long-messages .\src\SysYLexer.g4 .\src\SysYParser.g4
```

## 关于本仓库的文件范围

仓库只包含部分源码，以下内容因 `.gitignore` 规则或生成流程而不在其中：

- **SysY 文法文件**（`SysYLexer.g4`、`SysYParser.g4`）未提交，需自行提供后再执行 `make antlr`
- **ANTLR 生成的解析器**：`gen/` 下只有词法分析器 `SysYLexer.java`；`SysYParser.java` 及 `SysYParserBaseVisitor` 等由 `make antlr` 生成
- **部分业务类源码**：`llvmVisitor`、`RiscVBackEnd`、`IR_Optimization`、`Scope`、`Type`、`Error` 等被 `Main.java` 引用，但未纳入版本控制
- **第三方 jar**：ANTLR 与 LLVM 绑定的 jar 不在仓库内

因此直接克隆后无法立即 `make compile` 通过，需要补齐文法文件与依赖。仓库保留的是实验各阶段的状态记录。

## 提交脚本说明

`submit.sh` 将整个工作目录（含 `.git`）压缩为 `submit.zip`，要求工作区干净后再执行。脚本从当前分支名提取实验编号提交到课程 OJ：

```bash
MODULE=$(git rev-parse --abbrev-ref HEAD | tr '[a-z]' '[A-Z]')
```

`Makefile.git` 中的 `STUID` 与 `STUNAME` 是本项目的学号与姓名，`git_commit` 用固定 author 生成提交记录。

## 许可

见 [main 分支的 LICENSE](https://github.com/chenliang23/Compiler_Lab_Project/blob/main/LICENSE)（MIT License）。`master` 分支本身未包含 LICENSE 文件。
