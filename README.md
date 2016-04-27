# ExceptionReporter

**TODO: Add description**

## Configuration

config.exs

```
config :exception_reporter,
  filter_parameters: ["credentials"],
  relay: "localhost",
  port: 25,
  supported_envs: [:prod],
  sender: ~s(no-reply@a.com),
  recipients: ["a@a.com"]
```
