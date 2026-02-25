# Maaacks game template adoption

Link: https://github.com/Maaack/Godot-Game-Template

## Adoption flow

Quote from the template repo:
> This package is available as both a template and a plugin, meaning it can be used to start a new project, or added to an existing project.

This project was started without using this template. Switching to it functionality occurred much later, because I decided that writing everything from scratch was too slow and not effective (reinventing the wheel).
That's why initially it was used as a plugin (addon), and that's why I decided to separate its adoption into four steps:

1. **Integrating its functionality as an addon.**
   - This includes learning how it works, reusing some things and generally just see what smart people can do with Godot
1. **Untying core functionality from the addon** and implementing to main project infrastructure logic.
   - Addon comes with examples and also sometimes different implementation of the same thing.
   - We needed to take only parts which were reused during step 1 and also some parts which would be beneficial in the future.
   - Result is deleting the dependency, while still relying on big unedited parts of the vanilla functionality.
1. **Editing and shaping functionality**, deleting unnecessary things, refactoring what doesn't work for this project, etc
   - This step comes with a catch, because as long as the project grows, "what project needs" and "what doesn't work" are assumptions and tend to be changing.
1. Covering the result with tests, writing docs, and **living happily ever after**.

Naturally, second and third steps are most time consuming.

## Where we are

In the middle of the step three.

## What that means

Code is a mix and match of the original code and custom additions/refactoring.
Most of the architectural 'rails' are still the original ideas (and some of them will be staying this way, while some components, most notably UI options menu functionality is planned to be fully rewritten)
