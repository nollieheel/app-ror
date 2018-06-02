# app-ror cookbook

Some cookbook resources to ease setup of Ruby-on-Rails apps.

## Supported Platforms

Ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['app-ror']['example']</tt></td>
    <td>String</td>
    <td>Example attrib</td>
    <td><tt>'Some string'</tt></td>
  </tr>
</table>

## Usage

### app-ror::default

Include `app-ror` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[app-ror::default]"
  ]
}
```

## Resources

Example resources:

### app_ror_example

Description of the resource

### Actions

- `enable` - Enable the thing (default)
- `disable` - Disable the thing

### Properties:

- `name` - (optional) Name of the thing to enable.

## License and Authors

Author:: Earth U (<iskitingbords @ gmail.com>)
