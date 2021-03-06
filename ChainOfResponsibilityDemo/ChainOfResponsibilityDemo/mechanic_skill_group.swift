//
//  mechanic_skill_group.swift
//  Mechanic - Chain Of Responsibility
//
//  Created by Reza Shirazian on 2016-04-10.
//  Copyright © 2016 Reza Shirazian. All rights reserved.
//

import Foundation

class MechanicSkillGroup {
    
    var mechanics: [Mechanic]
    var nextLevel: MechanicSkillGroup?
    var skill: Skill
    
    init(skill: Skill, mechanics: [Mechanic], nextLevel: MechanicSkillGroup?) {
        self.mechanics = mechanics
        self.skill = skill
        self.nextLevel = nextLevel
    }
    
    func firstAvailableMechanicForJobWithSkillLevel(job: Job) -> Bool {
        if (job.minimumSkillSet > skill || mechanics.filter({!$0.isBusy}).isEmpty) {
            if let nextLevel = nextLevel {
                return nextLevel.firstAvailableMechanicForJobWithSkillLevel(job: job)
            } else {
                print("No one is available to do this job")
                return false
            }
        } else {
            if let firstAvailableMechanic = mechanics.filter({!$0.isBusy}).first {
                return firstAvailableMechanic.performJob(job)
            }
            assert(false, "This should never be reached, our if-else statement is fully exhaustive. " +
                "You cannot have both all mechanics busy and an available mechanic within one skill group")
        }
    }

    func performJobOrPassItUp(_ job: Job) -> Bool{
        if (job.minimumSkillSet > skill || mechanics.filter({$0.isBusy == false}).count == 0){
            if let nextLevel = nextLevel{
                return nextLevel.performJobOrPassItUp(job)
            }else{
                print("No one is available to do this job")
                return false
            }
        }else{
            if let firstAvailableMechanic = mechanics.filter({$0.isBusy == false}).first{
                return firstAvailableMechanic.performJob(job)
            }
            assert(false, "This should never be reached since our if-else statment is fully exhaustive. You cannot have both all mechanics busy and an available mechanic within one skill group");
        }
    }
}
