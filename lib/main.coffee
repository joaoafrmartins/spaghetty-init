{ resolve } = require 'path'

{ readFileSync } = require 'fs'

ACliCommand = require 'a-cli-command'

class Init extends ACliCommand

  command:

    name: "init"

    triggers: ["init"]

    options:

      init:

        type: "boolean"

      force:

        alias: "f"

        type: "boolean"

        description: [
          "dont prompt user for input",
          "and accept package-init prompt",
          "default values instead"
        ]

      templates:

        alias: "t"

        type: "array"

        description: [
          "specify with templates should",
          "be applied by package-init"
        ]

      data:

        description: [
          "the context data to be used",
          "with as the package-init default",
          "field. Data can be a JSON object",
          "or a filepath to a file in JSON",
          "format and object keys should",
          "specify package-init prompt",
          "default values",
          "ex.: --data {'package.name':'name'}"
        ]

  "execute?": (command, next) ->

    if command.args.init

      PackageInit = require 'package-init'

      @shell

      dest = pwd()

      { force, templates, data } = command.args

      templates = if Array.isArray templates then templates else false

      interactive = if typeof force is "undefined" then true else false

      if data

        try

          data = JSON.parse data

        catch err

          try

            data = JSON.parse readFileSync(resolve(data)).toString()

          catch err

            return next "invalid data field #{data}", null

      options =

        dest: dest

        data: data

        templates: templates

        interactive: interactive

      return PackageInit.run options, (err, results) =>

        if err then return next err, null

        results.map (tmpl) =>

          tmpl.map (file) =>

            if dest = file?.dest

              if conflict = file?.conflict

                return @cli.console.warn "#{dest}"

              @cli.console.info "#{dest}"

        next null, results

    next null, null

module.exports = Init
