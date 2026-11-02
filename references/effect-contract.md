# 当前效果与精确参数

## 事实来源与读取顺序

此文件解释关键不变量；完整算法、舍入、色彩和回退以技能包内 assets/baseline 下逐平台源码为准，不需要访问任何原始仓库。manifest.json 的 group 字段标出 engine、interaction、button、tabbar、slider、selection、dialog、theme、preview、font、build。不要把快照文件全部加入项目：selection 与 feedback 等参考文件含其他控件，只迁移用户指定的部分及其必需依赖。快照中的相对目录仅作资源定位，目标目录、包名和构建结构由目标工程决定。

| 任务 | 必须读取的快照组 |
| --- | --- |
| 共用玻璃表面 | engine、theme，以及平台对应 build 配置 |
| Button | engine、interaction、button、theme |
| TabBar | engine、interaction、tabbar、theme |
| Slider | engine、interaction、slider（Kotlin）或 selection（Flutter）、theme |
| Switch | engine、interaction、selection、theme |
| Dialog | engine、interaction、dialog、theme；动作按钮还需 button |
| 文档效果对照 | 上述目标组以及 preview 中对应背景、宿主和示例 |

## 共用绘制链路

背景与前景分开录制。仅采样独立背景、轨道或 TabBar 标签副本，不采样镜片自身，不重新组合点击/语义插槽。坐标必须使用完整源到目标变换；不能简化为只减全局坐标，否则按压缩放和弹簧形变时采样会错位。

绘制顺序为外阴影 → 按实际 shape 裁切 → 采样背景的模糊和折射 → 角色底色 → 清晰的文字/图标 → 轮廓高光/显式边框；交互镜片另有现有内阴影。Button 无交互镜片的内阴影。Flutter 自定义边框在子树的 foreground decoration 绘制，默认轮廓由外部 foreground painter 绘制；显式边框存在时关闭 Button 默认轮廓，不叠加两套描边。

采样边界 padding = ceil(blur × 3 + edge)。Kotlin 光学参数以 dp 转为 px；Flutter 在逻辑单位构图，以固定 ratio 2 生成镜片采样图，背景录制 DPR 限于 [1,2]。保留两端各自链路，不擅自统一采样倍率。

圆角距离场、法线、圆弧折射、七波段色散、亮度和饱和度运算逐字复用 HyperGlassOptics.kt 的 shader / hyper_glass.frag。Flutter uniform 顺序与 painter 赋值必须相同。不得用渐变、普通 backdrop-filter 或只设 blur 替换该算法。

Android API≥33 使用 RuntimeShader；31–32 使用模糊回退；更低 API 不执行光学采样。Preview 使用 Skia RuntimeEffect。Flutter FragmentProgram 注册路径为 packages/flutter_hyper_ui/shaders/hyper_glass.frag，源资源在 ui/pubspec.yaml 的 shaders 下注册；异步加载前或失败时沿用当前回退。迁移包名时同步注册和加载路径，保证实际着色器成功加载。

## Button：本次确认的样式

p 为当前动画进度，截断到 [0,1]。两端均按以下连续函数驱动整颗按钮的材质，而非只移动前景。

| 参数 | 函数 | 静止 p=0 | 按住 p=1 |
| --- | --- | --- | --- |
| 缩放 | 1 − 0.025p | 1 | 0.975 |
| 整体透明度 | 1 − 0.08p | 1 | 0.92 |
| 模糊 | 8 − 2p | 8dp | 6dp |
| 折射边缘 | 12 + 2p | 12dp | 14dp |
| 折射位移 | 16 + 2p | 16dp | 18dp |
| 外阴影半径 | 6 − 1.5p | 6dp | 4.5dp |
| 外轮廓高光强度 H | 0.5 + 0.5p | 0.5 | 1 |
| shader highlight | 2H | 1 | 2 |

进入 85ms，松开/取消恢复 180ms；曲线 CubicBezier(0.23,1,0.32,1)。中断时从当前展示值变化，不用每帧重置到端点。Button 的 dispersion=0、depth=0、saturation=1、brightness=0，shader stroke=0.5dp。Button 不因 pressed 被归入 Selection/Thumb 的 interactive 分支。

外阴影为零偏移、零 spread 黑色，alpha 浅色 0.08、深色 0.18。不要恢复品牌色投影、原渐变，或增加第二层按钮阴影。

默认及 icon 的中性底面为白色，alpha 浅色 0.4、深色 0.34×0.4=0.136。filled 默认使用原语义背景 alpha×0.9。显式传入背景保留原始 alpha：Kotlin 的 colors=null 表示默认配色，显式 HyperButtonColors 不应用默认染色；Flutter 以 backgroundColor 是否为 null 区分。透明色是有效覆盖，不等同于未指定。

默认轮廓沿真实外缘绘制，宽 0.5dp，裁切外半边，左上到右下三段白色 alpha=[0.6H,0.04H,0.5H]，stops=[0,0.5,1]。语义配色的默认非 filled 线框用基色 alpha=0.35、宽0.5dp，替代默认外轮廓。保留 shader 本身的高光；不要因为外边框存在关闭内部折射高光。

按钮高38dp，文字按钮最小宽68dp，radius19dp；基础水平 padding14dp。Kotlin 另保留原布局额外1dp内容 padding，不能在移植时悄悄删掉。文字13sp、行高1.2、w600、字距0.05，文字按钮图标17dp、纯图标20dp、内容间距8dp。expanded 由宿主占满现有可用宽，不改变默认尺寸。

禁用 = enabled=false 或 onPressed=null：使用原 controlTrack、弱化前景、1dp 弱边框；无采样、阴影和按压。loading 仍显示正常玻璃和原进度图标，阻止点击；文字/图标的显示分支及状态归属沿用组件源码。

Kotlin 的 hyperNoRippleClickable 在 Initial pass 观察 down，clickable/combinedClickable 仍决定业务回调；Button 的材质进度与现有缩放/alpha进度各自保留。Flutter 的 ButtonSurface 外层监听首根指针并驱动整个表面，内层 HyperPressable 的 pressedScale/pressedOpacity 都设为1，不能双重缩放。离开命中区、up、cancel及失去可交互性后按源码恢复。保留 Flutter 减少动态效果分支：duration=0、scale=1，alpha/材质即时到位；不把它错误描述为普通 HyperPressable 的100ms分支。

## 其他角色的材质

以下单位为 dp/Flutter logical pixel，p 指对应组件自己的按压进度；不能直接代入 Button 的 tween。

| 角色 | blur | edge | amount | 其他 |
| --- | --- | --- | --- | --- |
| Navigation | 8 | 24 | 24 | shadow8，轮廓强度0.5；默认白底alpha浅0.4/深0.136 |
| Selection | 0 | 10p | 14p | dispersion=p；shadow8且alpha乘p；静止选中底浅黑/深白0.1(1−p)，额外黑0.03p |
| Thumb | 8(1−p) | 10p | 14p | dispersion=p；shadow4；底色alpha乘(1−p) |
| SwitchThumb | 8(1−p) | 5p | 10p | dispersion=p；shadow4；底色alpha乘(1−p) |
| Dialog | 浅16/深8 | 24 | 48 | shadow16，depth1，saturation1.5，浅色brightness0.2，默认白底alpha浅0.6/深0.272 |

Selection/Thumb/SwitchThumb 的内阴影与边缘绘制按各端源码保留。Button 与 Navigation 有相同外缘绘制规则，但其他角色在 Flutter 使用内缩0.5、宽0.75的原规则；不要为了“对齐”统一描边。

### 专用动效与布局

- TabBar：multiple 默认内容高56、镜片默认高48；single固定直径48。组内最多5项，组外最多1个独立动作，分开计数。并排垂直居中；不把外部消息入口移进组内，也不减少镜片高度或扩大独立按钮。
- TabBar 的 position/press 弹簧 stiffness1000、dampingRatio1、threshold0.001。active = pressed 或 abs(position−target) > (count−1)×0.025，接近目标后才释放镜片。scaleX/scaleY 的 active目标为78/56，分别采用 dampingRatio0.6/0.7、stiffness250。速度形变、panelOffset、按下即高光和释放拖动回正原式均见两端 TabBarMotion；不能以普通260ms平移替代。绘制层舒展及±4dp整栏位移不改变测量和命中，贴底分支不做整栏变换。
- Slider：点击/外部值定位与按压用临界阻尼1/1000，拖动值跟手，保留原回调时机；20dp滑块不放大。背景和轨道的来源叠加顺序、禁用分支从组件读取。
- Switch：保留原开关尺寸、轨道、滑块位置和 spring 进度；读取 HyperSelectionControls.kt / hyper_selection_controls.dart 的完整分支。不得套用 TabBar 的78/56缩放或 Button 的缩放。
- Dialog：保留250ms现有遮罩与显隐、面板宽高约束、Insets/IME、点击外部关闭和退出生命周期。不能把视觉容器替换成一个没有原生窗口/路由约束的通用缩放盒子。

Flutter SpringSimulation 以mass=1、damping=2×dampingRatio×sqrt(stiffness)映射，不直接将0.6等阻尼比填入damping。完整阈值、状态与速度连续性以快照为准。

## 预览环境

随包示例以 Kotlin ButtonDemo 为基准：350×680预览、顶部52、内容padding16、组内8/组间16。文案、Lucide图标、排列与loading状态来自快照的示例，不自行增删控制项。font 分组包含合并的 Roboto/Noto Sans SC 字体 hyper_ui_preview.ttf，preview 分组的 DocsTypography.kt 展示其使用方式；跨电脑比较文字轮廓时从包内取字体，并适配目标框架资源声明。Lucide 依赖版本记录在 build 分组，通过标准包管理器安装，不读取原电脑资源。

可采样底图：渐变stops=[0,0.52,1]，端点分别为主题accent和RGB154/130/215以28/255透明度叠到pageBackground；12个半径42的accent圆，alpha0.3，中心(x=width×i/11,y=height×((i%4+0.5)/4))。不能用纯白背景证明折射一致。

默认accent RGB71/111/232；success34/197/94、info59/130/246、warning245/158/11、danger239/68/68。默认pageBackground浅241/243/247、深17/19/24。完整主题令牌与禁用色读取theme组；字体、颜色由宿主覆盖时沿用覆盖值，不为复现截图强制改业务主题。

## 验收条件

1. 校验技能快照SHA，并把目标源码与对应快照逐段核对。纯import/package调整不等于允许改公式或默认值；记录必须适配的平台差异。
2. 匹配平台/API、渲染后端及版本、视口、DPR、字号缩放、字体、主题、背景、配置和受控状态。构建版本见build组；pubspec里的最低版本不是当时实际运行版本，不能据此宣称环境一致。
3. 对比静止p=0、按下过渡、按住p=1、释放过渡及恢复；还需取消、快速反向/连续点击、禁用、loading和自定义背景。采样底图应含高对比边缘，使错位、额外模糊和折射缺失可见。
4. TabBar另外验证点击远近项、拖动/取消/松手吸附、镜片伸缩、整栏反馈、single+multiple、5+1；Slider/Switch/Dialog分别核对自己的状态和生命周期。只对本次用户指定的组件执行这些分支。
5. 核对布局尺寸、滚动链路、命中和回调，不只看截图。构建通过不代表效果一致，静态截图不证明连续动效一致。
6. 用户授权运行时使用现有预览/构建；不新增单元测试和临时报告。若没有条件逐帧对照，明确“源码参数已固定，逐帧视觉一致性未验证”，不得声称已证明100%一致。
