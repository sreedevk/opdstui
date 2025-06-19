type Configuration* = ref object of RootObj
  initialUrl*: string

proc newConfiguration*(initialUrl: string): Configuration = 
  new(result)
  result.initialUrl = initialUrl
