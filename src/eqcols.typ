#let resolve-length(len, max: 0pt) = {
  if type(len) == length { return len }
  if type(len) == ratio { return max * len }
  if type(len) == fraction { return len / 1fr * max }
  panic("Cannot resolve the length " + repr(len))
}

/// Produce a balanced column layout.
#let eqcols(
  /// number of columns
  /// -> int 
  n,
  /// the content 
  /// -> content 
  body,
  /// shifting the final height 
  /// -> length | ratio 
  shift: 0cm,
  /// column gap 
  /// -> length | ratio
  gutter: 4%,
  /// show a red box for debugging 
  /// -> bool
  debug: false,
) = {
  let eqcols-id = counter("__eqcols")
  eqcols-id.step()
  context {
    let floating-figures = state("__figs_" + str(eqcols-id.get().at(0)), ())
    show figure.where(scope: "parent"): it => { floating-figures.update(x => x + (it,)) + it }

    layout(size => {
      let container-width = size.width
      let container-height = size.height
      let line-height = 1em.to-absolute()
      let gutter = resolve-length(gutter, max: container-width)
      let shift = resolve-length(shift, max: container-height)
      let column-width = { (container-width - (n - 1) * gutter) / n }

      let float-free-body = {
        show figure.where(scope: "parent"): none
        body
      }

      let float-free-one-column-size = measure(width: column-width, float-free-body)

      context {
        let all-floating-figures = floating-figures.final()
        let float-height = all-floating-figures
          .map(fig => measure(width: container-width, fig).height)
          .sum(default: 0pt)
        let raw-new-height = float-free-one-column-size.height / n + float-height + shift
        let new-height = calc.ceil((raw-new-height / 1pt) / (line-height / 1pt)) * line-height
        block(columns(n, body, gutter: gutter), height: new-height, stroke: if debug { red })
      }
    })
  }
}
