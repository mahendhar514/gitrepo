module.exports = {
  apps : [{
    name        : "local-streamer",
    cwd 		    : "$HOME/.localstr/",
    script      : "index.js",
    //watch       : "false",
    env_production: {
      NODE_ENV: "development",
    },
    exec_mode  : "fork_mode"
  }
  ]
}