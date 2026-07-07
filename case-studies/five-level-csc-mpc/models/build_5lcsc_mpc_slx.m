function build_5lcsc_mpc_slx()
% SAVE-VARIANT of adaptive_weight_arc.m (auto-derived, build byte-identical):
% builds the SAME verified 5L-CSC FCS-MPC Simscape model, simulates it, prints the
% same 4 gates, then SAVES it as a static .slx. No json side-effects (does not
% touch the frozen sweep_result.json). Point = passing baseline (Iq=72, fixed wbal=100).
Iq=72; mode='fixed'; p_base=100; p_kb=0; p_wmin=100; p_wmax=100; tag='fcsmpc';
% ADAPTIVE_WEIGHT_ARC  One (Iq, weight-law) point of the 5L CSC FCS-MPC sweep.
%
% Circuit = ../caseB_strict_protocol_2026-07-02/g24_closedloop.m reused VERBATIM
% (3-phase line-line grid string + AC link caps + 3 star DC-link inductors, no
% source, no precharge, closed-loop bootstrap). ONLY the controller weight term
% is changed: wbal(t) = clamp(base*(1+kb*|i_alpha-i_beta|/(Idc/40)), wmin, wmax).
% FIXED baseline = same code path with kb=0, wmin=wmax=wbal (identical everything
% else). Physics FROZEN per prereg.json; this file never touches the caseB dir.
%
% Appends one record to sweep_result.json (crash-safe temp+movefile) and closes
% its own model. Model name g24_aw_<tag> is unique per point (no crosstalk).

here = fileparts(mfilename('fullpath'));
P = struct('Idc',80,'L',5e-3,'Rr',0.05,'Vg',120,'f0',50, ...
           'Ts',20e-6,'Tstop',0.08,'Rc',1e-4,'Cl',10e-6,'Tlog','[1e-6 5e-7]', ...
           'Iac',Iq,'Iq',Iq,'kpE',500,'Imax',78, ...
           'wbal_base',p_base,'kb',p_kb,'wbal_min',p_wmin,'wbal_max',p_wmax);
targ = [P.Idc/2, P.Idc/2, -P.Idc];

mdl = 'g24_5lcsc_fcsmpc';
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl);
np = containers.Map('KeyType','char','ValueType','any');
swCtl = cell(3,3);
for r = 1:3
  for p = 1:3
    sb = sprintf('%s/SW%d%d',mdl,r,p);
    add_block('fl_lib/Electrical/Electrical Elements/Switch',sb,'Position',[150+p*120 r*130 200+p*120 40+r*130]);
    set_param(sb,'Threshold','0.5','R_closed',num2str(P.Rc));
    hh = get_param(sb,'PortHandles');
    addp(np,sprintf('rail%d',r),hh.LConn(1)); addp(np,sprintf('ph%d',p),hh.RConn(2));
    swCtl{r,p} = hh.RConn(1);
  end
end
% DC link: star N' -> CS -> L -> Rr -> rail bus (no source anywhere)
fbPS = cell(1,3);
for r = 1:3
  cs = sprintf('%s/CSr%d',mdl,r);
  add_block('fl_lib/Electrical/Electrical Sensors/Current Sensor',cs,'Position',[-40 r*130 0 40+r*130]);
  Lb = sprintf('%s/Lr%d',mdl,r);
  add_block('fl_lib/Electrical/Electrical Elements/Inductor',Lb,'Position',[30 r*130 80 34+r*130]);
  set_param(Lb,'l',num2str(P.L));
  Rb = sprintf('%s/Rr%d',mdl,r);
  add_block('fl_lib/Electrical/Electrical Elements/Resistor',Rb,'Position',[100 r*130 140 34+r*130]);
  set_param(Rb,'R',num2str(P.Rr));
  ih = get_param(cs,'PortHandles'); lp = get_param(Lb,'PortHandles'); rp = get_param(Rb,'PortHandles');
  addp(np,'NSTAR',ih.LConn(1));
  add_line(mdl, ih.RConn(2), lp.LConn(1));
  add_line(mdl, lp.RConn(1), rp.LConn(1));
  addp(np,sprintf('rail%d',r), rp.RConn(1));
  fbPS{r} = ih.RConn(1);
  tap(mdl, fbPS{r}, sprintf('iL_%d',r), -40, r*130-60, P.Tlog);
end
% AC side: grid as line-line AC source string X-Y, Y-Z (Y grounded) + link caps
w = 2*pi*P.f0; Vll = sqrt(3)*P.Vg;
s1 = [mdl '/Vg_XY']; s2 = [mdl '/Vg_YZ'];
add_block('fl_lib/Electrical/Electrical Sources/AC Voltage Source',s1,'Position',[900 120 950 170]);
add_block('fl_lib/Electrical/Electrical Sources/AC Voltage Source',s2,'Position',[900 320 950 370]);
set_param(s1,'amp',num2str(Vll),'frequency',num2str(P.f0),'shift','30','shift_unit','deg');
set_param(s2,'amp',num2str(Vll),'frequency',num2str(P.f0),'shift','-90','shift_unit','deg');
h1 = get_param(s1,'PortHandles'); h2 = get_param(s2,'PortHandles');
addp(np,'gX',h1.LConn(1)); addp(np,'gY',h1.RConn(1));
addp(np,'gY',h2.LConn(1)); addp(np,'gZ',h2.RConn(1));
c1 = [mdl '/C_XY']; c2 = [mdl '/C_YZ'];
add_block('fl_lib/Electrical/Electrical Elements/Capacitor',c1,'Position',[980 120 1030 170]);
add_block('fl_lib/Electrical/Electrical Elements/Capacitor',c2,'Position',[980 320 1030 370]);
set_param(c1,'c',num2str(P.Cl)); set_param(c2,'c',num2str(P.Cl));
q1 = get_param(c1,'PortHandles'); q2 = get_param(c2,'PortHandles');
addp(np,'gX',q1.LConn(1)); addp(np,'gY',q1.RConn(1));
addp(np,'gY',q2.LConn(1)); addp(np,'gZ',q2.RConn(1));
% phase injection sensors between switch bus and grid nodes
for p = 1:3
  cs = sprintf('%s/CSp%d',mdl,p);
  add_block('fl_lib/Electrical/Electrical Sensors/Current Sensor',cs,'Position',[760 p*130 810 40+p*130]);
  ih = get_param(cs,'PortHandles');
  addp(np,sprintf('ph%d',p),ih.LConn(1));
  addp(np,sprintf('g%c','X'+p-1),ih.RConn(2));
  tap(mdl, ih.RConn(1), sprintf('i_%d',p), 760, p*130-60, P.Tlog);
end
add_block('fl_lib/Electrical/Electrical Elements/Electrical Reference',[mdl '/GND'],'Position',[1080 230 1120 270]);
gp2 = get_param([mdl '/GND'],'PortHandles'); addp(np,'gY',gp2.LConn(1));
add_block('nesl_utility/Solver Configuration',[mdl '/SC'],'Position',[1150 230 1200 270]);
sp2 = get_param([mdl '/SC'],'PortHandles'); addp(np,'gY',sp2.RConn(1));
% controller cluster: ZOH rail currents -> MATLAB Fcn -> UnitDelay -> gates
add_block('simulink/Signal Routing/Mux',[mdl '/MuxI'],'Position',[300 640 305 720]);
set_param([mdl '/MuxI'],'Inputs','3');
mx = get_param([mdl '/MuxI'],'PortHandles');
for r = 1:3
  y = 600 + r*40;
  pz = sprintf('%s/P2S_fb%d',mdl,r);
  add_block('nesl_utility/PS-Simulink Converter',pz,'Position',[150 y 185 y+24]);
  zh = sprintf('%s/ZOH%d',mdl,r);
  add_block('simulink/Discrete/Zero-Order Hold',zh,'Position',[220 y 255 y+24]);
  set_param(zh,'SampleTime',num2str(P.Ts));
  pp = get_param(pz,'PortHandles'); zp = get_param(zh,'PortHandles');
  add_line(mdl, fbPS{r}, pp.LConn(1));
  add_line(mdl, pp.Outport(1), zp.Inport(1));
  add_line(mdl, zp.Outport(1), mx.Inport(r));
end
add_block('simulink/Sources/Digital Clock',[mdl '/DClk'],'Position',[300 760 345 784]);
set_param([mdl '/DClk'],'SampleTime',num2str(P.Ts));
cb = [mdl '/FCSMPC'];
add_block('simulink/User-Defined Functions/MATLAB Function',cb,'Position',[380 660 480 760]);
cfg = get_param(cb,'MATLABFunctionConfiguration');
cfg.FunctionScript = controller_code(P, targ);
cp = get_param(cb,'PortHandles');
dk = get_param([mdl '/DClk'],'PortHandles');
add_line(mdl, mx.Outport(1), cp.Inport(1));
add_line(mdl, dk.Outport(1), cp.Inport(2));
ud = [mdl '/UDgate'];
add_block('simulink/Discrete/Unit Delay',ud,'Position',[510 690 545 730]);
set_param(ud,'SampleTime',num2str(P.Ts),'InitialCondition','[0;1;0;0;1;0;0;1;0]');
up = get_param(ud,'PortHandles');
add_line(mdl, cp.Outport(1), up.Inport(1));
add_block('simulink/Signal Routing/Demux',[mdl '/DemuxG'],'Position',[580 620 585 800]);
set_param([mdl '/DemuxG'],'Outputs','9');
dm = get_param([mdl '/DemuxG'],'PortHandles');
add_line(mdl, up.Outport(1), dm.Inport(1));
for r = 1:3
  for p = 1:3
    c = (r-1)*3 + p;
    sp = sprintf('%s/SPS%d%d',mdl,r,p);
    add_block('nesl_utility/Simulink-PS Converter',sp,'Position',[630 600+c*24 665 620+c*24]);
    set_param(sp,'FilteringAndDerivatives','zero');
    pp = get_param(sp,'PortHandles');
    add_line(mdl, dm.Outport(c), pp.Inport(1));
    add_line(mdl, pp.RConn(1), swCtl{r,p});
  end
end
tw = [mdl '/TW_sidx'];
add_block('simulink/Sinks/To Workspace',tw,'Position',[520 780 580 804]);
set_param(tw,'VariableName','sidx','SaveFormat','Array','SampleTime',num2str(P.Ts));
tp = get_param(tw,'PortHandles');
add_line(mdl, cp.Outport(2), tp.Inport(1));
ks = keys(np);
for k = 1:numel(ks)
  h = np(ks{k});
  for m = 2:numel(h), add_line(mdl,h(1),h(m),'autorouting','on'); end
end
set_param(mdl,'StopTime',num2str(P.Tstop));

so = sim(mdl);
iL = [so.get('iL_1'), so.get('iL_2'), so.get('iL_3')];
ip = [so.get('i_1'),  so.get('i_2'),  so.get('i_3')];
sx = so.get('sidx');
n = size(iL,1); tlog = (0:n-1)'*1e-6 + 5e-7;
ss = tlog >= 0.04;                                 % steady = last 2 cycles
wgt = 2*pi*P.f0; tt = tlog(ss);

errs = iL(ss,:) - targ; emax = max(abs(errs),[],'all');
bal  = mean(abs(iL(ss,1) - iL(ss,2)));
w1 = tlog>=0.04 & tlog<0.06; w2 = tlog>=0.06 & tlog<=0.08;
bal1 = mean(abs(iL(w1,1)-iL(w1,2)));
bal2 = mean(abs(iL(w2,1)-iL(w2,2)));
noise_half = abs(bal1 - bal2);
lvls = unique(round(ip(ss,:)/(P.Idc/2)))*(P.Idc/2);
lvlset = [-80 -40 0 40 80];
levels_present = double(ismember(lvlset, lvls(:)'));
five_ok = isequal(sort(lvls(:)),[-80;-40;0;40;80]);
zero_used = sum(ismember(sx, [1 14 27]));
nstates = numel(unique(sx));
amp = zeros(1,3); thd = zeros(1,3);
for p = 1:3
  x = ip(ss,p);
  a = zeros(1,50);
  for hh = 1:50
    a(hh) = abs(2/numel(x) * sum(x .* exp(-1i*hh*wgt*tt)));
  end
  amp(p) = a(1);
  thd(p) = 100*sqrt(sum(a(2:50).^2))/a(1);
end
acerr = 100*max(abs(amp - P.Iac))/P.Iac;
thd_worst = max(thd);
% reconstruct the adaptive weight trajectory over the steady window (same law,
% logged imbalance) for diagnostics that the schedule actually moved
imb = abs(iL(ss,1)-iL(ss,2));
wtraj = min(max(P.wbal_base*(1 + P.kb*imb/(P.Idc/40)), P.wbal_min), P.wbal_max);

g_rail = emax/P.Idc < 0.10;
g_five = five_ok;
g_zero = zero_used > 0;
g_ac   = acerr < 15;
allpass = g_rail && g_five && g_zero && g_ac;

fprintf('\n[%s] Iq=%g mode=%s law(base=%g,kb=%g,min=%g,max=%g)\n', tag, Iq, mode, p_base, p_kb, p_wmin, p_wmax);
fprintf('  balance |ia-ib| = %.4f A (w1 %.4f / w2 %.4f, noise_half %.4f)\n', bal, bal1, bal2, noise_half);
fprintf('  rail_track %.3f%% (<10 %d) | five_levels %d | zeros %d(>0 %d) | ac_track %.2f%%(<15 %d)\n', ...
  100*emax/P.Idc, g_rail, g_five, zero_used, g_zero, acerr, g_ac);
fprintf('  THD/ph (%.2f, %.2f, %.2f)%% worst %.2f%% | states %d | wbal[%.1f..%.1f] mean %.1f\n', ...
  thd(1), thd(2), thd(3), thd_worst, nstates, min(wtraj), max(wtraj), mean(wtraj));
fprintf('  ALL 4 GATES: %s\n', string(allpass));

rec = struct('tag',tag,'Iq',Iq,'mode',mode, ...
  'wbal_base',p_base,'kb',p_kb,'wbal_min',p_wmin,'wbal_max',p_wmax, ...
  'balance_A',bal,'balance_w1',bal1,'balance_w2',bal2,'noise_half',noise_half, ...
  'rail_err_max_A',emax,'rail_track_pct',100*emax/P.Idc,'g_rail',double(g_rail), ...
  'levels_present',levels_present,'five_ok',double(g_five), ...
  'zero_used',zero_used,'g_zero',double(g_zero), ...
  'ac_amp',amp,'ac_err_pct',acerr,'g_ac',double(g_ac), ...
  'thd_pct',thd,'thd_worst_pct',thd_worst, ...
  'states_used',nstates,'wbal_lo',min(wtraj),'wbal_hi',max(wtraj),'wbal_mean',mean(wtraj), ...
  'all_gates_pass',double(allpass));

save_system(mdl, fullfile(here,[mdl '.slx']));
fprintf('  -> SAVED %s.slx in %s\n', mdl, here);
close_system(mdl,0);
end

function append_json(jf, rec)
recjson = jsonencode(rec);
if isfile(jf)
  txt = strtrim(fileread(jf));
  txt = [txt(1:end-1) ',' recjson ']'];
else
  txt = ['[' recjson ']'];
end
tmp = [jf '.tmp'];
fid = fopen(tmp,'w'); fwrite(fid,txt); fclose(fid);
movefile(tmp, jf);   % atomic-ish: a crash loses at most the current point
end

function code = controller_code(P, targ)
% Identical to g24_closedloop controller EXCEPT the balancing weight is now a
% clamped imbalance-feedback schedule computed each step from the measured rail
% imbalance |i1-i2|. kb=0 & wmin=wmax=base reduces it EXACTLY to a fixed wbal.
code = sprintf([ ...
'function [g, sidx] = fcsmpc(iL, t)\n' ...
'persistent s_prev\n' ...
'if isempty(s_prev), s_prev = 13; end\n' ...
'Vg = %.17g; L = %.17g; Rr = %.17g; Ts = %.17g; w = 2*pi*%.17g;\n' ...
't1 = %.17g; t2 = %.17g; t3 = %.17g;\n' ...
'Iq = %.17g; kpE = %.17g; Imax = %.17g; Idc = %.17g;\n' ...
'wbase = %.17g; kb = %.17g; wmin = %.17g; wmax = %.17g;\n' ...
'i1 = iL(1); i2 = iL(2); i3 = iL(3);\n' ...
'%% white-box adaptive balancing weight: strong only when imbalance is large\n' ...
'imbal = abs(i1 - i2);\n' ...
'wbal = wbase*(1 + kb*imbal/(Idc/40));\n' ...
'if wbal < wmin, wbal = wmin; end\n' ...
'if wbal > wmax, wbal = wmax; end\n' ...
'[u1,u2,u3] = vrail(s_prev, Vg, w, t);\n' ...
'h1 = i1 + (Ts/L)*(u1 - Rr*i1);\n' ...
'h2 = i2 + (Ts/L)*(u2 - Rr*i2);\n' ...
'h3 = i3 + (Ts/L)*(u3 - Rr*i3);\n' ...
'tn = t + Ts;\n' ...
'boot = (t < 0.03);\n' ...
'Estar = 0.5*L*(t1^2 + t2^2 + t3^2);\n' ...
'E = 0.5*L*(h1^2 + h2^2 + h3^2);\n' ...
'Pcmd = kpE*(Estar - E) + Rr*(h1^2 + h2^2 + h3^2);\n' ...
'Iact = 2*Pcmd/(3*Vg);\n' ...
'if Iact > Imax, Iact = Imax; elseif Iact < -Imax, Iact = -Imax; end\n' ...
'ir = zeros(3,1);\n' ...
'for p = 1:3\n' ...
'  th = w*tn - (p-1)*2*pi/3;\n' ...
'  ir(p) = -Iact*sin(th) + Iq*cos(th);\n' ...
'end\n' ...
'best = inf; sbest = 0;\n' ...
'for s = 0:26\n' ...
'  [v1,v2,v3] = vrail(s, Vg, w, tn);\n' ...
'  q1 = h1 + (Ts/L)*(v1 - Rr*h1);\n' ...
'  q2 = h2 + (Ts/L)*(v2 - Rr*h2);\n' ...
'  q3 = h3 + (Ts/L)*(v3 - Rr*h3);\n' ...
'  if boot\n' ...
'    J = (q1-t1)^2 + (q2-t2)^2 + (q3-t3)^2;\n' ...
'  else\n' ...
'    pa = floor(s/9); pb = mod(floor(s/3),3); pc = mod(s,3);\n' ...
'    j1 = 0; j2 = 0; j3 = 0;\n' ...
'    if pa==0, j1=j1+q1; elseif pa==1, j2=j2+q1; else, j3=j3+q1; end\n' ...
'    if pb==0, j1=j1+q2; elseif pb==1, j2=j2+q2; else, j3=j3+q2; end\n' ...
'    if pc==0, j1=j1+q3; elseif pc==1, j2=j2+q3; else, j3=j3+q3; end\n' ...
'    J = (j1-ir(1))^2 + (j2-ir(2))^2 + (j3-ir(3))^2 + wbal*(q1-q2)^2;\n' ...
'  end\n' ...
'  if J < best, best = J; sbest = s; end\n' ...
'end\n' ...
'pa = floor(sbest/9); pb = mod(floor(sbest/3),3); pc = mod(sbest,3);\n' ...
'g = zeros(9,1);\n' ...
'g(0*3+pa+1) = 1; g(1*3+pb+1) = 1; g(2*3+pc+1) = 1;\n' ...
'sidx = sbest + 1;\n' ...
's_prev = sbest;\n' ...
'end\n' ...
'function [v1,v2,v3] = vrail(s, Vg, w, t)\n' ...
'pa = floor(s/9); pb = mod(floor(s/3),3); pc = mod(s,3);\n' ...
'ga = Vg*sin(w*t - pa*2*pi/3);\n' ...
'gb = Vg*sin(w*t - pb*2*pi/3);\n' ...
'gc = Vg*sin(w*t - pc*2*pi/3);\n' ...
'cm = (ga+gb+gc)/3;\n' ...
'v1 = cm-ga; v2 = cm-gb; v3 = cm-gc;\n' ...
'end\n'], ...
P.Vg, P.L, P.Rr, P.Ts, P.f0, targ(1), targ(2), targ(3), P.Iq, P.kpE, P.Imax, P.Idc, ...
P.wbal_base, P.kb, P.wbal_min, P.wbal_max);
end

function tap(mdl, psPort, varName, x, y, Tlog)
p2 = sprintf('%s/P2S_%s',mdl,varName);
add_block('nesl_utility/PS-Simulink Converter',p2,'Position',[x y x+35 y+24]);
tw = sprintf('%s/TW_%s',mdl,varName);
add_block('simulink/Sinks/To Workspace',tw,'Position',[x+60 y x+120 y+24]);
set_param(tw,'VariableName',varName,'SaveFormat','Array','SampleTime',Tlog);
pp = get_param(p2,'PortHandles'); tp = get_param(tw,'PortHandles');
add_line(mdl, psPort, pp.LConn(1));
add_line(mdl, pp.Outport(1), tp.Inport(1));
end

function addp(map, node, h)
if isKey(map,node), map(node) = [map(node) h]; else, map(node) = h; end
end
