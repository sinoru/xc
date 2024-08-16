//
//  DataProtocol+XcApple.swift
//
//
//  Created by Jaehong Kang on 8/16/24.
//

import Foundation

extension DataProtocol {
    var leadingZeroBitCount: Int {
        let nonZeroByteIndex = (self.firstIndex(where: { $0 != 0 }) ?? self.startIndex)

        return self[startIndex...nonZeroByteIndex].reduce(into: 0) { partialResult, value in
            partialResult += value.leadingZeroBitCount
        }
    }
}
