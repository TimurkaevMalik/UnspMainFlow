//
//  GropedTasksManager.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 19.10.2025.
//

import Foundation

#warning("Move to NetworkKit")
final class GropedTasksManager<TaskGroup: Hashable, TaskID: Hashable> {
    
    struct TaskKey: Hashable {
        let group: TaskGroup
        let taskID: TaskID
    }
    
    private var tasks: [TaskKey: Task<(), Never>] = [:]
}

extension GropedTasksManager {
    func set(task: Task<(), Never>, for key: TaskKey) {
        tasks[key] = task
    }
    
    func get(for key: TaskKey) -> Task<(), Never>? {
        tasks[key]
    }
    
    func remove(for key: TaskKey) {
        tasks.removeValue(forKey: key)
    }
    
    func removeAll() {
        tasks.forEach({ $0.value.cancel() })
        tasks.removeAll()
    }
    
    func makeKey(_ key: TaskKey) -> TaskKey {
        key
    }
}
