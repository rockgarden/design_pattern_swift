//
//  job.swift
//  Mechanic - Chain Of Responsibility
//
//  Created by Reza Shirazian on 2016-04-07.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

/// 作业对象
class Job {
    let minimumSkillSet: Skill
    let name: String
    var completed: Bool = false
    
    init(minimumSkillSet: Skill, name: String, completed: Bool = false) {
        self.minimumSkillSet = minimumSkillSet
        self.name = name
        self.completed = completed
    }
}
