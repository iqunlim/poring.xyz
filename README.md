# Poring.xyz

Welcome to the front-end to [My S3-based Image Uploader!](https://files.iqun.xyz)

## Installation instructions

`git clone https://github.com/iqunlim/poring.xyz`
`cd poring-xyz && npm install`
`npm run dev` to run in developer mode
`npm run build` to build the project in to a distributatble format

```

## Features

![Gif of a poring](https://files.iqun.xyz/GMZ6TTB4ET0B/poring.gif)

Porings. Everyone loves cute jelly monsters.

Ctrl + V and Drag and drop support for image files

Handles images up to 20MB in size

## Project Goal

The goal of this project was to make an image uploader to an [AWS S3 bucket](https://aws.amazon.com/what-is/object-storage/) using an API located on AWS along with a netlify or vercel-hosted front-end.

I largely used the front end part of this project as a way to practice using event listeners in react, learn zod functionality for dealing with API return validation, and to work with the new [useActionState](https://react.dev/reference/react/useActionState) hook from React 19

Libraries, etc. used:

[Typescript](https://www.typescriptlang.org/)

[React](https://react.dev/)

[Zod](https://zod.dev/)

[Tailwindcss](https://tailwindcss.com)

[Terraform](https://www.terraform.io/). You can find the terraform setup (with setups for a web server via AWS ECS instead of netlify) [here](https://github.com/iqunlim/poring.xyz.terraform)

## Challenges

In the front end, zod took quite some time to get my head around. I ended up looking at tutorials specific to zod and reading the documentation extensively to get the most out of the incredible typescript-extending library.

Learning to work with the browser API and the ways it worked took up a large amount of my time as well. I spend a lot of time reading the MDN docs and looking
at some example code in order to make it work with the next part that was tricky...

Using the new useActionState hook. This hook is very new with few examples, requiring me to understand how it worked based off of the react documentation.

## Future Plans - From most likely to least likely

Proper build and deployment steps, including making the API url an environment variable of some kind

A Dark mode (Deviling mode to those Ragnarok Online nerds out there)

Remake the API / make this project a nextjs application

Extend this beyond image uploads with a different storage solution backend and file chunking to allow larger stable uploads.

Additional functionality such as logins and file tracking.

## Acknowledgements

[Total Typescript](https://www.totaltypescript.com/) and their excellent Zod tutorial series

[Exampro](https://www.exampro.co/) for their AWS and Terraform lessons

### License

Both the terraform and the front end are licensed under GPL-3
```
