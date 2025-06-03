import XCTest
@testable import Core

final class MarkdownParserTests: XCTestCase {
    func testParseEmptyText() {
        XCTAssertThrowsError(try MarkdownParser.parse("")) { error in
            XCTAssertEqual(error as? MarkdownParser.MarkdownError, .invalidFormat)
        }
    }
    
    func testParseCodeBlocks() throws {
        let input = """
        这是一个代码块：
        ```swift
        let x = 1
        let y = 2
        ```
        这是普通文本。
        """
        
        let result = try MarkdownParser.parse(input)
        XCTAssertTrue(result.contains("let x = 1"))
        XCTAssertTrue(result.contains("let y = 2"))
        XCTAssertFalse(result.contains("```"))
    }
    
    func testParseLists() throws {
        let input = """
        有序列表：
        1. 第一项
        2. 第二项
        3. 第三项
        
        无序列表：
        * 项目一
        - 项目二
        + 项目三
        """
        
        let result = try MarkdownParser.parse(input)
        XCTAssertTrue(result.contains("• 第一项"))
        XCTAssertTrue(result.contains("• 第二项"))
        XCTAssertTrue(result.contains("• 第三项"))
        XCTAssertTrue(result.contains("• 项目一"))
        XCTAssertTrue(result.contains("• 项目二"))
        XCTAssertTrue(result.contains("• 项目三"))
    }
    
    func testParseHeaders() throws {
        let input = """
        # 标题1
        ## 标题2
        ### 标题3
        """
        
        let result = try MarkdownParser.parse(input)
        XCTAssertTrue(result.contains("标题1"))
        XCTAssertTrue(result.contains("标题2"))
        XCTAssertTrue(result.contains("标题3"))
        XCTAssertFalse(result.contains("#"))
    }
    
    func testParseEmphasis() throws {
        let input = """
        这是**粗体**文本，这是*斜体*文本。
        """
        
        let result = try MarkdownParser.parse(input)
        XCTAssertTrue(result.contains("粗体"))
        XCTAssertTrue(result.contains("斜体"))
        XCTAssertFalse(result.contains("**"))
        XCTAssertFalse(result.contains("*"))
    }
    
    func testParseComplexMarkdown() throws {
        let input = """
        # 主标题
        
        这是一个**重要**的段落，包含*强调*文本。
        
        ## 代码示例
        ```swift
        func example() {
            print("Hello")
        }
        ```
        
        ## 列表
        1. 第一项
        2. 第二项
        * 子项1
        * 子项2
        """
        
        let result = try MarkdownParser.parse(input)
        XCTAssertTrue(result.contains("主标题"))
        XCTAssertTrue(result.contains("重要"))
        XCTAssertTrue(result.contains("强调"))
        XCTAssertTrue(result.contains("func example()"))
        XCTAssertTrue(result.contains("• 第一项"))
        XCTAssertTrue(result.contains("• 第二项"))
        XCTAssertTrue(result.contains("• 子项1"))
        XCTAssertTrue(result.contains("• 子项2"))
    }
    
    func testParseEscapedCharacters() throws {
        let input = "这是\\n换行符，这是\\\"引号"
        let result = try MarkdownParser.parse(input)
        XCTAssertTrue(result.contains("\n"))
        XCTAssertTrue(result.contains("\""))
        XCTAssertFalse(result.contains("\\n"))
        XCTAssertFalse(result.contains("\\\""))
    }
} 