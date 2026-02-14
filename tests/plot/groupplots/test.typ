#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

// Test default groupplots
#test-case({
  groupplots(
    2, (3, 3),
    horizontal-sep: 1, vertical-sep: 1,
    title: "Global Title", // global title
    sublabels: "(a)",
    
    // Plot 1: with title
    (title: "Plot 1"), { plot.add(((0,0), (1,1))) },
    
    // Plot 2: with title and custom style
    (title: "Plot 2", title-style: (offset: (0, 0.5))), { plot.add(((0,0), (1,1))) },
    
    // Plot 3: empty options (should use defaults)
    (), { plot.add(((0,0), (1,1))) },
    
    // Plot 4: with options but no title
    (x-label: "X Label"), { plot.add(((0,0), (1,1))) }
  )
})

// Test regular plot with title
#test-case({
  plot.plot(
     size: (3,3),
     title: "Regular Plot Title",
     title-style: (padding: 0.5cm),
     { plot.add(((0,0), (1,1))) }
  )
})

// Test user example from cetz_groupplots.typ
#test-case({
  let factor = -10
  groupplots(
    3,                  // 3 columns
    (4, 4),             // plot size
    horizontal-sep: 1.5, vertical-sep: 1.5, 
    title: "Global Title", 
    sublabels: "(a)", 
    x-tick-step: 1,
    y-tick-step: 1,
    (x-tick-step: 0.5, title: "Plot 1"), 
    { plot.add(((0,0), (1,1), (2,0.5), (4,3))) },
    (),                 
    { plot.add(((0,0), (1,1), (2,0.5), (4,-3))) },
    (x-tick-step: 2),
    { plot.add(((0,0), (1,1), (2,0.5), (4,3)))
     plot.add(((0,0), (1,1), (2,0.5), (4,-3))) },
    (x-tick-step: 4, y-tick-step: 10000),
    { plot.add(((0,0), (1,10000), (2,5000), (4,30000))) },
    (x-tick-step: 4, y-tick-step: 1*calc.abs(factor)),
    { plot.add(((0,0), (1,1*factor), (2,0.5*factor), (4,3*factor))) },
    (x2-tick-step: 4, y2-tick-step: 100000),
    { plot.add(axes: ("x2", "y2"), ((0,0), (1,100000), (2,50000), (4,300000))) }
  )
})
