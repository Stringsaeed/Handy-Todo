// Shared helpers for the handy marketing pages. Loads the app's own vector icons
// from Assets.xcassets so every mark matches the interface.
const ASSETS = "../../HandyTodo/Assets.xcassets";
const ICON_FILES = {
  add: "HandyAdd.imageset/Add.svg",
  calendar: "HandyCalendar.imageset/Calendar.svg",
  circle: "HandyCircle.imageset/Circle.svg",
  close: "HandyClose.imageset/Close.svg",
  completed: "HandyCompleted.imageset/Completed.svg",
  feedback: "HandyFeedback.imageset/Feedback.svg",
  muted: "HandyMuted.imageset/Muted.svg",
  settings: "HandySettings.imageset/Settings.svg",
  shuffle: "HandyShuffle.imageset/Shuffle.svg",
  sound: "HandySound.imageset/Sound.svg",
};

const Handy = {
  icons: {},

  async load() {
    await Promise.all(Object.entries(ICON_FILES).map(async ([name, file]) => {
      const text = await (await fetch(`${ASSETS}/${file}`)).text();
      Handy.icons[name] = text
        .replace(/<\?xml[^>]*>/, "")
        .replace(/<!--.*?-->/g, "")
        .replace(/#080808/g, "currentColor")
        .replace(/width="\d+" height="\d+"/, "");
    }));
    await document.fonts.load('40px "Oregano"');
    await document.fonts.ready;
  },

  icon(name, cls = "") {
    return Handy.icons[name].replace("<svg ", `<svg class="${cls}" `);
  },

  // A loose hand-drawn loop (the app's circle stroke, stretched) around a word.
  circled(word, color = "var(--accent)") {
    return `<span class="mark circled">${word}<svg class="scribble" viewBox="198 29 50 49" preserveAspectRatio="none">
      <path d="m223.4 32.67c-13.15 0.608-21.34 10.27-21.44 21.63 0.352 10.59 6.624 18.08 15.1 20.16 2.304 0.192 4.832 0.768 7.104 0.352 2.848-0.608 5.536-0.896 7.904-2.336 7.712-4 11.84-10.82 11.78-19.49-0.096-10.56-7.04-18.91-16.13-19.78-1.472-0.224-2.912-0.544-4.32-0.544z"
        fill="none" stroke="${color}" stroke-width="5" stroke-linecap="round" vector-effect="non-scaling-stroke"/></svg></span>`;
  },

  underlined(word, color = "var(--accent)") {
    return `<span class="mark underlined">${word}<svg class="scribble" viewBox="0 0 100 12" preserveAspectRatio="none">
      <path d="M2 8.5 C 18 5.5, 34 4.2, 52 5.6 S 84 9, 98 3.8" fill="none" stroke="${color}" stroke-width="7"
        stroke-linecap="round" vector-effect="non-scaling-stroke"/></svg></span>`;
  },

  phone(src, w = 900, extra = "") {
    const media = src.endsWith(".mp4") ? `<video src="${src}" muted playsinline></video>` : `<img src="${src}">`;
    return `<div class="phone" style="--w:${w}px" ${extra}><div class="screen">${media}<div class="island"></div></div></div>`;
  },

  tablet(src, w = 1500, extra = "") {
    return `<div class="tablet" style="--w:${w}px" ${extra}><div class="screen"><img src="${src}"></div></div>`;
  },

  // Data mirrors the seeded demo store: unfinished tasks, Primary first.
  widgetTasks: [
    ["finish the pitch deck", "primary"],
    ["call mom back", "primary"],
    ["plan the weekend hike", "secondary"],
    ["water the plants", "secondary"],
  ],

  widget(size, pt, { date = "oct 3", remaining = 6, finished = 3, dark = false } = {}) {
    const small = size === "small";
    const tasks = Handy.widgetTasks.slice(0, small ? 1 : 4).map(([t, c]) => `
      <div class="task">${Handy.icon("circle")}<div><div class="t">${t}</div>${small ? "" : `<div class="c">${c}</div>`}</div></div>`).join("");
    const style = dark ? "background:var(--paper-dark);color:var(--ink-dark);--accent:var(--accent-dark)" : "";
    return `<div class="widget ${size}" style="--pt:${pt}px;${style}">
      <div class="date">${date}</div>
      <div class="count"><b>${remaining}</b><span>things to do</span></div>
      ${tasks}
      <div class="spacer"></div>
      ${small ? "" : `<div class="foot">${finished} finished · one thing at a time</div>`}
    </div>`;
  },

  // The layered app icon from HandyIcon.icon, drawn as SVG so the video can animate it.
  iconSVG(cls = "") {
    return `<svg class="${cls}" viewBox="0 0 1024 1024">
      <defs><clipPath id="squircle"><rect width="1024" height="1024" rx="230"/></clipPath>
        <filter id="lift" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="0" dy="22" stdDeviation="26" flood-color="#5b1d08" flood-opacity="0.35"/></filter></defs>
      <g clip-path="url(#squircle)">
        <rect class="ic-bg" width="1024" height="1024" fill="#b74c2a"/>
        <g filter="url(#lift)">
          <rect class="ic-back" x="224" y="176" width="584" height="656" rx="86" transform="rotate(-12 512 512)" fill="#e7c899"/>
          <rect class="ic-paper" x="220" y="190" width="584" height="656" rx="86" fill="#fff5dc"/>
        </g>
        <path class="ic-check" d="M356 418 L464 526 L672 310" fill="none" stroke="#293c31" stroke-width="78" stroke-linecap="round" stroke-linejoin="round"/>
        <path class="ic-lines" d="M356 644 H665 M356 722 H542" fill="none" stroke="#293c31" stroke-opacity="0.32" stroke-width="30" stroke-linecap="round"/>
      </g>
    </svg>`;
  },
};
