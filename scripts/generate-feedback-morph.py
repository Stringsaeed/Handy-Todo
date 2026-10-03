from pathlib import Path
import re,xml.etree.ElementTree as ET,math
root=Path(__file__).resolve().parents[1]
parts=list(ET.parse(root/'Design/InterfaceIcons.svg').getroot())[0]
def flatten(d):
 tokens=re.findall(r'[A-Za-z]|[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][-+]?\d+)?',d)
 points=[];x=y=0.;start=(0.,0.);i=0;cmd=None
 while i<len(tokens):
  if tokens[i].isalpha():cmd=tokens[i];i+=1
  rel=cmd.islower();op=cmd.lower()
  if op=='z':points.append(start);x,y=start;cmd=None;continue
  n={'m':2,'l':2,'h':1,'v':1,'c':6}[op];a=list(map(float,tokens[i:i+n]));i+=n
  if op in ['m','l']:
   x,y=(x+a[0],y+a[1]) if rel else (a[0],a[1]);points.append((x,y))
   if op=='m':start=(x,y);cmd='l' if rel else 'L'
  elif op=='h':x=x+a[0] if rel else a[0];points.append((x,y))
  elif op=='v':y=y+a[0] if rel else a[0];points.append((x,y))
  else:
   p0=(x,y);p1=(x+a[0],y+a[1]) if rel else (a[0],a[1]);p2=(x+a[2],y+a[3]) if rel else (a[2],a[3]);p3=(x+a[4],y+a[5]) if rel else (a[4],a[5])
   for step in range(1,21):
    t=step/20;u=1-t;points.append(tuple(u**3*p0[k]+3*u*u*t*p1[k]+3*u*t*t*p2[k]+t**3*p3[k] for k in [0,1]))
   x,y=p3
 return points
def sample(index,bounds):
 if index is None:return [(0.5,0.5)]*48
 pts=flatten(parts[index].attrib['d']);length=[0.]
 for a,b in zip(pts,pts[1:]):length.append(length[-1]+math.dist(a,b))
 out=[];seg=0;bx,by,side=bounds
 for k in range(48):
  dist=length[-1]*k/47
  while seg<len(pts)-2 and length[seg+1]<dist:seg+=1
  span=length[seg+1]-length[seg];f=(dist-length[seg])/span if span else 0
  x,y=(pts[seg][j]+f*(pts[seg+1][j]-pts[seg][j]) for j in [0,1]);out.append(((x-bx)/side,(y-by)/side))
 return out
geometries={'soundsOn':([2,3,4,5],(66,97,58)), 'soundsOff':([8,7,6,None],(132,97,56)), 'hapticsOn':([9,10,11,12,13],(194,95,58)), 'hapticsOff':([24,25,26,None,None],(31,174,56))}
s='import CoreGraphics\n\n// Generated from Design/InterfaceIcons.svg by scripts/generate-feedback-morph.py.\nenum HandyMorphPaths {\n'
for name,(indices,bounds) in geometries.items():
 s+='    static let '+name+': [[CGPoint]] = [\n'
 for i in indices:
  s+='        ['+', '.join('CGPoint(x: %.5f, y: %.5f)'%xy for xy in sample(i,bounds))+'],\n'
 s+='    ]\n'
s+='}\n';(root/'Shared/HandyMorphPaths.swift').write_text(s)
