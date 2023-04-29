//
//  main.swift
//  MyCreditManager
//
//  Created by My on 2023/04/28.
//

import Foundation

enum FunctionType: String {
    case addStudent = "1"
    case deleteStudent = "2"
    case addGradeOrChangeGrade = "3"
    case deleteGrade = "4"
    case showGrade = "5"
    case exit = "X"
    case none
}

class MyCreditManager {
    let userDefault = UserDefaults.standard
    
    func startService() {
        entranceMent()
        selectFunction()
    }
    
    private func entranceMent() {
        print("원하는 기능을 입력해주세요")
        print("1: 학생추가, 2: 학생삭제, 3: 성적추가(변경), 4: 성적삭제, 5: 평점보기, X: 종료")
    }

    private func selectFunction() {
        let functionString = readLine()!
        let functionType = FunctionType(rawValue: functionString) ?? .none
                
        if isInvalidFunction(function: functionType) {
            switch functionType {
            case .addStudent: self.addStudent()
            case .deleteStudent: self.deleteStudent()
            case .addGradeOrChangeGrade: self.addGradeOrChangeGrade()
            case .deleteGrade: self.deleteGrade()
            case .showGrade: self.showGrade()
            case .exit: self.exit()
            default: break
            }
        } else {
            print("뭔가 입력이 잘못되었습니다. 1~5 사이의 숫자 혹은 X를 입력해주세요.")
        }
        
        startService()
    }
    
    private func isInvalidFunction(function: FunctionType?) -> Bool {
        guard let function = function else { return false }
        return function == .addStudent || function == .deleteStudent || function == .addGradeOrChangeGrade || function == .deleteGrade || function == .showGrade || function == .exit
    }
}

// MARK: Function
extension MyCreditManager {
    private func addStudent() {
        print("추가할 학생의 이름을 입력해주세요")
        
        let name = readLine()!.trimmingCharacters(in: .whitespaces)
        
        if name.isEmpty {
            print("입력이 잘못되었습니다. 다시 확인해주세요.")
            return
        }
        
        if let _ = userDefault.dictionary(forKey: name) {
            print("\(name)은 이미 존재하는 학생입니다. 추가하지 않습니다.")
        } else {
            let grade = ["":""]
            userDefault.set(grade, forKey: name)
            print("\(name) 학생을 추가했습니다.")
        }
    }
    
    private func deleteStudent() {
        print("삭제할 학생의 이름을 입력해주세요")
        
        let name = readLine()!.trimmingCharacters(in: .whitespaces)
        if let _ = userDefault.dictionary(forKey: name) {
            userDefault.removeObject(forKey: name)
            print("\(name) 학생을 삭제하였습니다.")
        } else {
            print("\(name) 학생을 찾지 못했습니다.")
        }
    }
    
    private func addGradeOrChangeGrade() {
        print("성적을 추가할 학생의 이름, 과목 이름, 성적(A+, A, F 등)을 띄어쓰기로 구분하여 차례로 작성해주세요.")
        print("입력예) Mickey Swift A+")
        print("만약에 학생의 성적 중 해당 과목이 존재하면 기존 점수가 갱신됩니다.")
        
        let gradeInformation = readLine()!.split(separator: " ")
        guard !gradeInformation.isEmpty else {
            print("입력이 잘못되었습니다. 다시 확인해주세요.")
            return
        }
        let isValidInformationForm = gradeInformation.count == 3
        
        if isValidInformationForm {
            let name = String(gradeInformation[0])
            let subject = String(gradeInformation[1])
            let grade = String(gradeInformation[2])
            
            var gradeDictionary = userDefault.dictionary(forKey: name)!
            if gradeDictionary.count == 1 {
                gradeDictionary.removeValue(forKey: "")
            }
            gradeDictionary.updateValue(grade, forKey: subject)
            
            userDefault.set(gradeDictionary, forKey: name)
            print("\(name) 학생의 \(subject) 과목이 \(grade)로 추가(변경)되었습니다.")
        } else {
            print("입력이 잘못되었습니다. 다시 확인해주세요.")
        }
    }
    
    private func deleteGrade() {
        print("성적을 삭제할 학생의 이름, 과목 이름을 띄어쓰기로 구분하여 차례로 작성해주세요.")
        print("입력예) Mickey Swift")
        
        let subjectInformation = readLine()!.split(separator: " ")
        guard !subjectInformation.isEmpty else {
            print("입력이 잘못되었습니다. 다시 확인해주세요.")
            return
        }
        let isValidSubjectInformationForm = subjectInformation.count == 2
        
        if isValidSubjectInformationForm {
            let name = String(subjectInformation[0])
            let subject = String(subjectInformation[1])
            
            guard var gradeDictionary = userDefault.dictionary(forKey: name),
                  gradeDictionary.count > 0 else {
                print("\(name) 학생을 찾지 못했습니다.")
                return
            }
            
            if gradeDictionary[subject] != nil {
                gradeDictionary.removeValue(forKey: subject)
                
                userDefault.set(gradeDictionary, forKey: name)
                print("\(name) 학생의 \(subject) 과목의 성적이 삭제되었습니다.")
            } else {
                print("\(name) 학생은 \(subject) 과목을 이수하지 않았습니다.")
            }
        } else {
            print("입력이 잘못되었습니다. 다시 확인해주세요.")
        }
    }
    
    private func showGrade() {
        print("평점을 알고싶은 학생의 이름을 입력해주세요.")
        
        let name = readLine()!.trimmingCharacters(in: .whitespaces)
        if name.isEmpty {
            print("입력이 잘못되었습니다. 다시 확인해주세요.")
        } else if let gradeInformation = userDefault.dictionary(forKey: name) {
            if gradeInformation.isEmpty {
                print("\(name) 학생은 이수한 과목이 없습니다.")
            } else {
                var totalGrade = Float(0.0)
                let subjectCount = Float(gradeInformation.count)
                for grade in gradeInformation {
                    print("\(grade.key): \(grade.value)")
                    totalGrade += "\(grade.value)".changeToScore()
                }
                print(totalGrade/subjectCount)
            }
        } else {
            print("\(name) 학생을 찾지 못했습니다.")
        }
    }
    
    private func exit() {
        print("프로그램을 종료합니다...")
        Darwin.exit(0)
    }
}

let myCreditManager = MyCreditManager()
myCreditManager.startService()

//gitKraken Test
