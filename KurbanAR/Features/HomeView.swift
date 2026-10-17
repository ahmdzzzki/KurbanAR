import SwiftUI

struct HomeView: View {
    @Binding var tab: AppTab
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("selectedAnimal") private var selectedAnimal = AnimalSpecies.cattle.rawValue
    @AppStorage("completedLessons") private var saved = ""
    @State private var about = false
    @State private var sceneVisible = false
    private var species: AnimalSpecies { AnimalSpecies(rawValue: selectedAnimal) ?? .cattle }
    private var progress: LearningProgress { LearningProgress(saved: saved) }
    var body: some View {
        ZStack {
            if sceneVisible { AnimalSceneView(species:species,autoRotate:!reduceMotion).ignoresSafeArea() }
            VStack {
                LinearGradient(colors:[Palette.midnight.opacity(0.95),.clear],startPoint:.top,endPoint:.bottom).frame(height:320)
                Spacer()
                LinearGradient(colors:[.clear,Palette.midnight],startPoint:.top,endPoint:.bottom).frame(height:380)
            }.ignoresSafeArea().allowsHitTesting(false)
            VStack(alignment:.leading,spacing:18) {
                HStack {
                    Label("kurbanar",systemImage:"sparkle").font(.title3.weight(.bold))
                    Spacer()
                    Button { about = true } label: {
                        Label("Pendamping",systemImage:"person.2.fill").font(.caption.weight(.semibold)).padding(.horizontal,13).frame(height:44)
                            .background(.white.opacity(0.10),in:Capsule())
                    }.accessibilityLabel("Untuk pendamping")
                }
                HStack(spacing:8) {
                    Circle().fill(Palette.gold).frame(width:6,height:6)
                    Text("AYO JADI SAHABAT KURBAN").font(.system(size:10,weight:.medium,design:.monospaced)).tracking(2)
                }.foregroundStyle(Palette.gold)
                Text("Halo, penjelajah!\nAyo kenali kurban.")
                    .font(.system(size:37,weight:.heavy,design:.rounded)).minimumScaleFactor(0.7)
                Text("Kenalan dengan hewan. Belajar peduli. Serunya berbagi!").font(.subheadline).foregroundStyle(.white.opacity(0.6))
                Spacer(minLength:20)
                HStack(alignment:.bottom) {
                    VStack(alignment:.leading,spacing:5) {
                        Text("TEMAN JELAJAH / \(species.index)").font(.caption2.monospaced()).tracking(2).foregroundStyle(Palette.gold)
                        Text(species.title).font(.system(size:30,weight:.medium,design:.serif))
                    }
                    Spacer()
                    Button { tab = .studio } label: {
                        Label("JELAJAH 3D",systemImage:"viewfinder").font(.caption2.weight(.bold))
                            .padding(12).background(.white.opacity(0.10),in:Capsule())
                    }.buttonStyle(.plain).accessibilityLabel("Buka Studio AR")
                }
                AnimalPicker(selection:$selectedAnimal)
                Button { tab = .learn } label: {
                    HStack {
                        Image(systemName:"star.fill")
                        Text("Mulai misi belajar")
                        Spacer()
                        Image(systemName:"arrow.up.right")
                    }.font(.subheadline.weight(.semibold)).padding(19).foregroundStyle(Palette.midnight)
                        .background(Palette.linen,in:RoundedRectangle(cornerRadius:20))
                }.buttonStyle(.plain).accessibilityLabel("Mulai misi belajar")
                HStack(spacing:15) {
                    Button { tab = .learn } label: {
                        VStack(alignment:.leading,spacing:5) {
                            Label("Misi belajar",systemImage:"star.fill").font(.caption.weight(.medium))
                            Text("\(progress.completed.count) dari \(Lesson.all.count) bintang").font(.caption2).foregroundStyle(.white.opacity(0.5))
                        }.frame(maxWidth:.infinity,alignment:.leading)
                    }
                    Rectangle().fill(.white.opacity(0.15)).frame(width:1,height:30)
                    Button { tab = .day } label: {
                        VStack(alignment:.leading,spacing:5) {
                            Label("Hari Kurban",systemImage:"sun.max.fill").font(.caption.weight(.medium))
                            Text("Ikuti cerita panitia").font(.caption2).foregroundStyle(.white.opacity(0.5))
                        }.frame(maxWidth:.infinity,alignment:.leading)
                    }
                }.buttonStyle(.plain).padding(.top,5)
            }.padding(.horizontal,24).padding(.top,8).padding(.bottom,12).frame(maxWidth:700)
        }.background(Palette.midnight).foregroundStyle(.white)
            .onAppear { sceneVisible = true }
            .onDisappear { sceneVisible = false }
            .sheet(isPresented:$about) { FamilyGuideView() }
    }
}
