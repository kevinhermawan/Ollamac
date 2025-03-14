//
//  Chat-Export.swift
//  Ollamac
//
//  Created by Philipp on 06.02.2025.
//

import CoreTransferable

extension Chat: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .plainText) { chat in
            chat.markdown().data(using: .utf8) ?? Data()
        }
    }
}

extension Chat {
    var chatName: String {
        return name.isEmpty ? "New Chat" : name.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
    }

    var chatFilename: String {
        chatName.replacingOccurrences(of: " ", with: "_") + ".md"
    }

    func markdown() -> String {
        let sortedMessages = messages.sorted(by: { $0.createdAt < $1.createdAt })

        let name = chatName
        var markdown = "# \(name)\n\n## Conversation\n\n"

        for message in sortedMessages {

            // User prompt (plain text)
            let prompt = message.prompt
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\n", with: "\n> ")
                .replacingOccurrences(of: "\n> \n", with: "\n>\n")
            markdown += "### User\n\n> \(prompt)\n\n"

            // response (markdown)
            var response = message.response?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            // process <think> block by indenting its content and escaping HTML tags
            if let start = response.ranges(of: "<think>").first {
                if let end = response.ranges(of: /<\/think>\s+/).last {
                    var thinkBlock = String(response[start.upperBound..<end.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)

                    // Escape HTML special characters
                    thinkBlock = thinkBlock
                        .replacingOccurrences(of: "&", with: "&amp;")
                        .replacingOccurrences(of: "<", with: "&lt;")
                        .replacingOccurrences(of: ">", with: "&gt;")

                    // Indent for blockquote formatting
                    thinkBlock = "> " + thinkBlock.replacingOccurrences(of: "\n", with: "\n> ")
                    thinkBlock = thinkBlock.replacingOccurrences(of: "\n> \n", with: "\n>\n")

                    // Replace the <think> block in the response with formatted content
                    response.replaceSubrange(start.lowerBound..<end.upperBound, with: thinkBlock+"\n\n")
                }
            }
            markdown += "### AI\n\n\(response)\n\n"

            markdown += "---\n\n"
        }

        markdown += """
        ## Stats
        
        | **Property** | **Value** |
        |--------------|-----------------------------|
        | Model        | \(model) |
        | Created at   | \(createdAt.formatted(date: .numeric, time: .complete)) |
        | Modified at  | \(modifiedAt.formatted(date: .numeric, time: .complete)) |
        | Messages     | \(messages.count) |

        """

        if let host = host {
            markdown += "| Host        | \(host) |\n"
        }

        if let systemPrompt = systemPrompt {
            markdown += "| System Prompt | \(systemPrompt.replacingOccurrences(of: "\n", with: " ")) |\n"
        }

        if let temperature = temperature {
            markdown += "| Temperature  | \(temperature) |\n"
        }

        if let topP = topP {
            markdown += "| Top P       | \(topP) |\n"
        }

        if let topK = topK {
            markdown += "| Top K       | \(topK) |\n"
        }

        return markdown
    }

}
