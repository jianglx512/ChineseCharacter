//
//  ContentView.swift
//  ChineseCharacter
//
//  Created by Lixiang Jiang on 2021-05-16.
//

import SwiftUI
import CoreData

class CoreDataViewModel: ObservableObject {
    let container : NSPersistentContainer
    @Published var savedCharacters: [CharacterEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "CharacterContainer")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error happened. \(error)")
            }
        }
        
        fetchCharacters()
    }
    
    private func fetchCharacters(){
        let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
        
        do {
            savedCharacters = try container.viewContext.fetch(request)
        } catch let error {
            print("Error on fetching. \(error)")
        }
    }
    
    private func populateModelToText(savedCharacters: [CharacterEntity]) -> String{
        let sortedCharacters: [CharacterEntity] = savedCharacters.sorted(by: { $0.index < $1.index })
        var showText = String()
        for (_, character) in sortedCharacters.enumerated(){
            showText.append(String(character.display ?? ""))
        }
        return showText
    }
    
    private func populateTextToModel(str : String) -> [CharacterEntity] {
        var characters: [CharacterEntity] = []
        for (index, char) in str.enumerated(){
            let newChar = CharacterEntity(context: container.viewContext)
            newChar.display = String(char)
            newChar.index = Int16(index)
            characters.append(newChar)
        }
        return characters
    }
    
    private func saveData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CharacterEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest:fetchRequest)
        
        do {
            try container.viewContext.execute(deleteRequest)
            try container.viewContext.save()
            fetchCharacters()
        } catch let error {
            print("Error on saving. \(error)")
        }
    }
    
    func saveCharacters(str: String) {
        savedCharacters = populateTextToModel(str: str)
        saveData()
        //characterString = populateModelToText(savedCharacters: cvm.savedCharacters)
    }
    
    func loadCharacters() -> String {
        fetchCharacters()
        return populateModelToText(savedCharacters: savedCharacters)
    }
}

struct ContentView: View {
    
    @State var characterString: String = ""
    @State var cvm = CoreDataViewModel()
    
    func initLoading() {
        characterString = cvm.loadCharacters()
    }
    
    func saveAction() {
        cvm.saveCharacters(str: characterString)
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $characterString)
                .frame(height: 600)
                .colorMultiply(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                .cornerRadius(10)
                .onChange(of: characterString, perform: { value in
                    saveAction()
                })
            
            HStack {
                Button(action: {
                    
                }, label: {
                    Text("开始认字".uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                })
            }
            
            Spacer()
        }.padding()
        .onAppear(){
            initLoading()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
