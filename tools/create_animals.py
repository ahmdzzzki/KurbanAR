import bpy, math, random, os
from mathutils import Vector
random.seed(37)
out=os.path.abspath(os.environ['KURBAN_ASSET_OUTPUT'])
os.makedirs(out,exist_ok=True)

def material(name, rgb, rough=.75):
 m=bpy.data.materials.new(name);m.diffuse_color=(*rgb,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*rgb,1);p.inputs['Roughness'].default_value=rough
 return m
brown=material('Warm chestnut coat',(.34,.15,.065));light=material('Warm short coat',(.48,.27,.12));dark=material('Charcoal muzzle',(.055,.042,.03),.5)
ivory=material('Ivory horn',(.62,.51,.34));hoof=material('Cloven hoof',(.10,.075,.05));eye=material('Dark amber eye',(.018,.012,.008),.17)
cream=material('Warm fleece',(.77,.72,.60));sock=material('Pale lower legs',(.65,.60,.47));inner=material('Inner ear',(.29,.15,.11));black=material('Sheep face',(.12,.095,.065));wools=[material('Fleece '+str(i),(.72+i*.022,.675+i*.021,.57+i*.018)) for i in range(5)]

def uv(name,pos,scale,mat,seg=24,rings=16):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=seg,ring_count=rings,location=pos)
 ob=bpy.context.object;ob.name=name;ob.scale=scale;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if mat:ob.data.materials.append(mat)
 for f in ob.data.polygons:f.use_smooth=True
 return ob

def link(name,a,b,r1,r2,mat,vertices=16):
 d=Vector(b)-Vector(a);mid=(Vector(a)+Vector(b))/2
 bpy.ops.mesh.primitive_cone_add(vertices=vertices,radius1=r1,radius2=r2,depth=d.length,location=mid)
 o=bpy.context.object;o.name=name;o.rotation_euler=d.to_track_quat('Z','Y').to_euler();o.data.materials.append(mat)
 for f in o.data.polygons:f.use_smooth=True
 return o

def tube(name,pts,radii,mat,segments=10):
 verts=[];faces=[]
 for i,p in enumerate(pts):
  tangent=Vector(pts[min(i+1,len(pts)-1)])-Vector(pts[max(i-1,0)])
  tangent.normalize();u=tangent.cross(Vector((0,0,1)))
  if u.length<.01:u=tangent.cross(Vector((0,1,0)))
  u.normalize();v=tangent.cross(u)
  for j in range(segments):
   q=Vector(p)+radii[i]*(math.cos(j*math.tau/segments)*u+math.sin(j*math.tau/segments)*v);verts.append(q)
 for i in range(len(pts)-1):
  for j in range(segments):a=i*segments+j;b=i*segments+(j+1)%segments;faces.append((a,b,b+segments,a+segments))
 faces.extend([tuple(range(segments-1,-1,-1)),tuple((len(pts)-1)*segments+j for j in range(segments))])
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.materials.append(mat)
 ob=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(ob)
 for p in mesh.polygons:p.use_smooth=True
 return ob

def merge(parts,name,voxel=None):
 bpy.ops.object.select_all(action='DESELECT')
 for o in parts:o.select_set(True)
 bpy.context.view_layer.objects.active=parts[0];bpy.ops.object.join();o=bpy.context.object;o.name=name
 if voxel:
  mod=o.modifiers.new('Continuous anatomical surface','REMESH');mod.mode='VOXEL';mod.voxel_size=voxel;bpy.ops.object.modifier_apply(modifier=mod.name)
  mod=o.modifiers.new('Soften transitions','SMOOTH');mod.factor=1.2;mod.iterations=6;bpy.ops.object.modifier_apply(modifier=mod.name)
  mod=o.modifiers.new('Mobile mesh','DECIMATE');mod.ratio=.48;bpy.ops.object.modifier_apply(modifier=mod.name)
 for p in o.data.polygons:p.use_smooth=True
 return o

def clear():
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)

def cow():
 clear();parts=[]
 for name,pos,scale in [('Rib cage',(0,0,1.11),(.88,.34,.46)),('Haunch',(-.63,0,1.2),(.33,.32,.38)),('Shoulders',(.54,0,1.25),(.34,.32,.41)),('Neck',(.87,0,1.35),(.33,.235,.40)),('Head',(1.13,0,1.45),(.30,.19,.24)),('Face bridge',(1.34,0,1.31),(.22,.155,.26)),('Dewlap',(.91,0,1.04),(.14,.11,.30))]:parts.append(uv(name,pos,scale,brown))
 for side in [-1,1]:
  for front in [-1,1]:
   x=.57 if front==1 else -.64;y=side*.235
   hip=(x,y,1.12);knee=(x+(.055 if front==1 else -.11),y,.58);ankle=(x+.06,y,.15)
   parts.extend([uv('Muscle',hip,(.145,.125,.32),brown),link('Upper leg',hip,knee,.075,.10,brown),uv('Joint',knee,(.078,.068,.085),brown),link('Lower leg',knee,ankle,.044,.06,brown)])
   uv('Pale sock',(ankle[0],y,.20),(.054,.056,.145),sock)
   for s in [-1,1]:uv('Split hoof',(ankle[0]+.025,y+s*.028,.065),(.09,.028,.062),hoof)
 merge(parts,'CattleCoat',.024)
 uv('Muzzle',(1.49,0,1.18),(.17,.175,.115),dark)
 for side in [-1,1]:
  uv('Nostril',(1.58,side*.11,1.21),(.036,.023,.018),black)
  uv('Eye socket',(1.22,side*.172,1.49),(.064,.028,.053),dark)
  uv('Eye',(1.23,side*.193,1.50),(.032,.012,.026),eye)
  uv('Eye glint',(1.241,side*.202,1.511),(.008,.004,.007),cream)
  ear=uv('Ear',(1.035,side*.27,1.62),(.155,.105,.035),brown);ear.rotation_euler.x=side*.27
  ear=uv('Inner ear',(1.05,side*.275,1.641),(.106,.074,.012),inner);ear.rotation_euler.x=side*.27
  tube('Horn',[(1.0,side*.12,1.64),(.96,side*.18,1.74),(.92,side*.22,1.88),(.95,side*.22,1.99)],[.052,.043,.027,.002],ivory)
 tube('Tail',[(-.85,0,1.35),(-.99,.035,1.15),(-1.04,.07,.85),(-1.03,.10,.62)],[.045,.033,.023,.015],brown)
 uv('Tail tassel',(-1.03,.10,.58),(.055,.045,.14),dark)
 # Subtle coat details, muzzle lip and shallow folds, rather than cartoon markings.
 tube('Mouth',[(1.60,-.13,1.135),(1.635,0,1.13),(1.60,.13,1.135)],[.006,.006,.006],black)
 return 'sapi'

def sheep():
 clear();parts=[]
 for name,pos,scale in [('Body',(0,0,.69),(.59,.25,.32)),('Rump',(-.4,0,.74),(.25,.24,.27)),('Neck',(.46,0,.80),(.19,.17,.29)),('Head',(.65,0,.97),(.20,.12,.17)),('Long face',(.79,0,.86),(.18,.103,.17))]:parts.append(uv(name,pos,scale,black if name in ['Head','Long face'] else cream))
 # Separate coherent fleece and face surfaces preserve natural face proportions.
 merge(parts[:3],'Fleece base',.02);merge(parts[3:],'Sheep face',.014)
 for side in [-1,1]:
  for x in [-.37,.36]:
   a=(x,side*.17,.66);b=(x+.025,side*.17,.30);c=(x+.015,side*.17,.08)
   link('Upper leg',a,b,.038,.065,black);uv('Knee',b,(.043,.04,.045),black);link('Lower leg',b,c,.027,.033,black)
   for s in [-1,1]:uv('Cloven hoof',(c[0]+.012,c[1]+s*.016,.043),(.050,.018,.042),hoof,16,10)
  ear=uv('Ear',(.63,side*.19,1.01),(.12,.10,.025),black);ear.rotation_euler.x=side*.4
  uv('Eye',(.741,side*.105,.979),(.030,.012,.025),eye)
  uv('Eye glint',(.75,side*.116,.988),(.006,.003,.006),cream,12,8)
  # Curved ram horns, tapered rings following an anatomical arc.
  pts=[];rs=[]
  for i in range(28):
   t=i/27;angle=.4+t*4.6
   pts.append((.53-.12*math.sin(angle),side*(.13+.1*math.sin(t*math.pi)),1.02+.155*math.cos(angle)))
   rs.append(.054*(1-t)**.7+.002)
  tube('Curved horn',pts,rs,ivory,12)
 uv('Nose',(.936,0,.80),(.035,.070,.042),dark)
 tube('Mouth',[(.935,-.06,.772),(.952,0,.765),(.935,.06,.772)],[.004,.004,.004],dark)
 uv('Tail',(-.61,0,.72),(.09,.07,.15),cream)
 # Dense small wool locks follow an ellipsoid, with deterministic variation.
 tufts=[]
 for i in range(970):
  z=1-2*(i+.5)/970;angle=i*2.3999632297;r=math.sqrt(1-z*z)
  p=(.60*r*math.cos(angle)-.04,.265*r*math.sin(angle),.70+.325*z)
  if p[2]<.46:continue
  size=random.uniform(.025,.045)
  tufts.append(uv('Wool lock',p,(size*1.15,size,size*.9),random.choice(wools),10,6))
 merge(tufts,'Textured wool locks')
 return 'domba'

def export(name):
 bpy.ops.object.select_all(action='SELECT')
 bpy.ops.wm.usd_export(filepath=os.path.join(out,name+'.usdz'),selected_objects_only=True,export_animation=False,export_materials=True,generate_preview_surface=True)
 print('EXPORTED',name,'objects',len(bpy.context.scene.objects),'triangles',sum(len(o.data.polygons) for o in bpy.context.scene.objects if o.type=='MESH'))
 # Render only for visual verification of the actual 3D asset.
 bpy.context.scene.render.engine='CYCLES';bpy.context.scene.cycles.samples=32
 world=bpy.data.worlds.new('Soft daylight');bpy.context.scene.world=world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.55,.62,.5,1);world.node_tree.nodes['Background'].inputs[1].default_value=.7
 bpy.ops.mesh.primitive_plane_add(size=200);bpy.context.object.data.materials.append(material('Render ground',(.23,.29,.19)))
 bpy.ops.object.light_add(type='AREA',location=(3,-4,6));bpy.context.object.data.energy=800;bpy.context.object.data.shape='DISK';bpy.context.object.data.size=5
 target=Vector((0,0,.75 if name=='sapi' else .5));bpy.ops.object.camera_add(location=(3.5,-5,2.5) if name=='sapi' else (2.6,-3.5,1.8));cam=bpy.context.object;cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.lens=58;bpy.context.scene.camera=cam
 bpy.context.scene.render.resolution_x=1200;bpy.context.scene.render.resolution_y=1000;bpy.context.scene.render.resolution_percentage=100;bpy.context.scene.render.filepath=os.path.join(out,name+'-verify.png');bpy.ops.render.render(write_still=True)

for make in [cow,sheep]:export(make())
