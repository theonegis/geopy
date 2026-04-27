#import "@preview/touying:0.6.1": *
#import "@preview/zh-kit:0.1.0": *
#import themes.university: *

#let primary-blue = rgb("#0D47A1")
#let secondary-blue = rgb("#1E88E5")
#let tertiary-blue = rgb("#2962FF")

// 将图片路径提取出来作为函数参数 bg-image
#let new-section-slide(
  bg-image: none,
  config: (:),
  level: 1,
  numbered: true,
  toc-font-size: 28pt,
  toc-spacing: 1em,
  body,
) = touying-slide-wrapper(self => {
  let slide-body = {
    set std.align(horizon)
    show: pad.with(10%)
    context {
      let headings = query(heading.where(level: level))
      let current = headings.filter(h => h.location().page() <= here().page()).last()

      stack(
        dir: ttb,
        spacing: toc-spacing,
        ..headings.map(h => {
          let is-current = (current != none and h.location() == current.location())
          let color = if is-current { self.colors.primary } else { gray }

          stack(
            dir: ttb,
            spacing: 0.4em,
            text(size: toc-font-size, fill: color, weight: "bold", {
              if numbered and h.numbering != none {
                numbering(h.numbering, ..counter(heading).at(h.location()))
                [ ]
              }
              h.body
            }),
            if is-current {
              block(
                height: 2pt,
                width: 100%,
                spacing: 0pt,
                components.progress-bar(height: 2pt, self.colors.primary, self.colors.primary-light),
              )
            },
          )
        }),
      )
    }
    body
  }
  let background-body = {
    if bg-image != none {
      // 1. Image + Overlay (full page consistency)
      place(top + left, image(bg-image, width: 100%, height: 100%, fit: "cover"))
      place(top + left, rect(width: 100%, height: 100%, fill: white.transparentize(50%)))

      // 2. White Mask (covering bottom part with a curve)
      place(top + left, curve(
        fill: white,
        curve.move((0%, 100%)),
        curve.line((100%, 100%)),
        curve.line((100%, 25%)),
        curve.cubic((60%, 45%), (30%, 5%), (0%, 25%)),
        curve.close(),
      ))
    }
  }
  touying-slide(self: self, config: config + (page: (background: background-body)), slide-body)
})

// 代码块卡片封装（带行号）
#let code-card(content, size: 0.9em) = align(center)[#block(
  fill: rgb("#FAFAFA"),
  stroke: 1pt + rgb("#E0E0E0"),
  inset: (x: 1.2em, y: 1em),
  radius: 8pt,
  width: 95%,
  align(left)[
    #{
      set text(size: size)
      show raw.line: l => {
        box(width: 0pt, move(dx: -3.2em, box(width: 1.5em, align(right)[#text(
          fill: rgb("#A0A0A0"),
          size: size,
        )[#l.number]])))
        l.body
      }
      content
    }
  ],
)]

// 主题封装
#let course-theme(
  title: "",
  author: "",
  institution: "",
  date: datetime.today().display("[year]年[month]月[day]日"),
  bg-image: none,
  logo-image: none,
  toc-font-size: 28pt,
  toc-spacing: 0.8em,
  code-font-size: 0.9em,
  body,
) = {
  show: university-theme.with(
    config-colors(
      primary: primary-blue,
      primary-dark: primary-blue.darken(20%),
      primary-light: primary-blue.lighten(50%),
      secondary: secondary-blue,
      secondary-dark: secondary-blue.darken(20%),
      secondary-light: secondary-blue.lighten(50%),
      tertiary: tertiary-blue,
      tertiary-dark: tertiary-blue.darken(20%),
      tertiary-light: tertiary-blue.lighten(50%),
      neutral: rgb("#000000"),
      neutral-light: rgb("#ffffff"),
      neutral-dark: rgb("#000000"),
    ),
    aspect-ratio: "16-9",
    align: horizon,
    header-right: if logo-image != none { align(horizon, pad(right: 1em, image(logo-image, height: 1.5em))) } else {
      none
    },
    config-common(
      new-section-slide-fn: new-section-slide.with(
        bg-image: bg-image,
        toc-font-size: toc-font-size,
        toc-spacing: toc-spacing,
      ),
    ),
    config-page(
      margin: (top: 2.5em),
    ),
    config-info(
      title: text(size: 1.5em)[#title],
      author: text(size: 1.6em)[#author],
      institution: text(size: 1.3em)[#institution],
      date: date,
    ),
  )

  set text(size: 22pt)
  show heading.where(level: 3): set text(size: 23pt, weight: "bold")
  show figure: set align(center)
  show table: set align(center)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: image): set figure.caption(position: bottom)
  set figure(numbering: none, gap: 1.5em)
  show figure.caption: set text(size: 22pt, weight: "bold")
  set table(inset: 10pt)

  set par(justify: true, first-line-indent: 0pt)

  show raw: set text(size: code-font-size)
  show raw.where(block: true): it => code-card(it, size: code-font-size)

  body
}

// 标题页封装
#let course-title-slide(bg-image: none, logo-image: none) = {
  set page(background: if bg-image != none {
    place(image(bg-image, width: 100%, height: 100%, fit: "cover"))
    place(rect(width: 100%, height: 100%, fill: white.transparentize(50%)))
  } else { none })

  if logo-image != none {
    title-slide(logo: image(logo-image, width: 8cm))
  } else {
    title-slide()
  }
}

// 可复用的高亮内容块
#let titled-card(title, content) = align(center)[#block(
  fill: primary-blue.lighten(95%),
  stroke: 1pt + primary-blue.lighten(60%),
  inset: (x: 1.2em, y: 0.8em),
  radius: 10pt,
  width: 95%,
  align(left)[
    #set par(first-line-indent: 0pt)
    #stack(
      dir: ttb,
      spacing: 0.8em,
      text(weight: "bold", size: 1.1em, fill: primary-blue.darken(40%), title),
      line(length: 100%, stroke: 0.5pt + primary-blue.lighten(50%)),
      text(size: 0.95em, content),
    )
  ],
)]

// 不带标题的背景卡片，内容垂直居中、左对齐
#let bg-card(content) = align(center)[#block(
  fill: primary-blue.lighten(95%),
  stroke: 1pt + primary-blue.lighten(60%),
  inset: (x: 1.2em, y: 1.2em),
  radius: 10pt,
  width: 95%,
  align(horizon)[
    #align(left)[
      #set par(first-line-indent: 0pt)
      #text(size: 0.95em, content)
    ]
  ],
)]
