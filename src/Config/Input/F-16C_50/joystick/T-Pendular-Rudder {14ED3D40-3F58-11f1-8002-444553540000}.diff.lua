local diff = {
  ["axisDiffs"] = {
    ["a2001cdnil"] = {
      ["removed"] = {
        [1] = { ["key"] = "JOY_Y" },
      },
      ["name"] = "Pitch",
    },
    ["a2002cdnil"] = {
      ["removed"] = {
        [1] = { ["key"] = "JOY_X" },
      },
      ["name"] = "Roll",
    },
    ["a2003cdnil"] = {
      ["added"] = {
        [1] = { ["key"] = "JOY_Z" },
      },
      ["name"] = "Rudder",
    },
    ["a2004cdnil"] = {
      ["removed"] = {
        [1] = { ["key"] = "JOY_Z" },
      },
      ["name"] = "Thrust",
    },
    ["a2112cdnil"] = {
      ["added"] = {
        [1] = { ["key"] = "JOY_Y", ["filter"] = { ["curvature"] = {  }, ["deadzone"] = 0, ["invert"] = true, ["saturationX"] = 1, ["saturationY"] = 1, ["slider"] = false } },
      },
      ["name"] = "Wheel Brake Left",
    },
    ["a2113cdnil"] = {
      ["added"] = {
        [1] = { ["key"] = "JOY_X", ["filter"] = { ["curvature"] = {  }, ["deadzone"] = 0, ["invert"] = true, ["saturationX"] = 1, ["saturationY"] = 1, ["slider"] = false } },
      },
      ["name"] = "Wheel Brake Right",
    },
  },
}
return diff
