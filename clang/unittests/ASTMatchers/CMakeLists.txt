add_clang_unittest(ASTMatchersTests
  ASTMatchersInternalTest.cpp
  ASTMatchersNodeTest.cpp
  ASTMatchersNarrowingTest.cpp
  ASTMatchersTraversalTest.cpp
  GtestMatchersTest.cpp
  CLANG_LIBS
  clangAST
  clangASTMatchers
  clangBasic
  clangFrontend
  clangSerialization
  clangTooling
  LINK_LIBS
  clangTesting
  LLVMTestingSupport
  LLVM_COMPONENTS
  FrontendOpenMP
  Support
  TargetParser
  )

add_subdirectory(Dynamic)
