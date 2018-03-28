# Getting Zeit's Now working with CircleCI

If you've been working or even dabbling with [Zeit's realtime deployment service Now](https://zeit.co/now) for a while, you've probably considered setting up
some sort of a CI workflow. This repo will help guide you through getting Now deployments working with CircleCI.

## Prerequisites

This repo assumes a few basic things in order to illustrate how CI can work with Now for your projects (this isn't going to be exhaustive by any stretch, but should help you get started). Prerequisites:

1. You have [a paid Now account](https://zeit.co/account/plan) with Zeit. This example repo assumes you have access to use the custom domains feature.
2. You have a [CircleCI](https://circleci.com/) account - paid or FREE.
3. You have either used Github to log in to CircleCI or have linked up your Github account in some form to it (or other git repository for that matter).
4. You're ok to use CircleCI 2.0.
5. This repo assumes a basic [Git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) - with Master > Develop > Feature Branches. You can of course customize it as you see fit.

## Getting Started

1. Fork this repo to your Github account.
2. Add/setup a new project in CircleCI for this new forked repo (you'll only need to make some minor modifications to configure your domain).
3. Go to your Now dashboard, and [add a token](https://zeit.co/account/tokens). You should see a slightly hidden field in the middle of the page that says "Create a new token by entering its name..." I'd recommend calling it something obvious like `zeit-now-circleci-yourproject`.
4. Take the token from Step 2, and add an Environment Variable in your project's settings in CircleCI. This sample repo calls it `ZEIT_TOKEN`, so I'd suggest doing something similar - if you change it, be aware that you'll need to change references to this token name in the sample files.

## Doing your first deploy to Now via CircleCI

1. Once you're all setup with a fork of this repo, and your CircleCI project is configured, let's create a feature branch and publish it. In CircleCI, you should see it FAIL. This is expected.
2. The reason it fails is that the `now.json` files are trying to alias to my personal domain niccai.com. You'll need to open and update the following files to reflect your custom domain that your Now project uses:

```
.now/now.feature.sh
.now/now.production.json
.now/now.staging.json
```

3. Each of the above `now.json` files represent different configurations in Git flow. Production is used for the master branch, staging for develop, and feature for feature branches. You'll notice that the feature now.json is actually a shell script with `.sh`. The reason for this is that this file actually dynamically creates a `now.json` for each of your feature branches and aliases it respectively. It's the only way to dynamically alias using Now that I am aware of.
4. Once you have updated the domain references for your aliases, your next push to Github should deploy to now. [Here's what you should see](https://master-circleci-now.niccai.com/).

## So, what is actually happening here?

Well, it's actually pretty easy to understand, and for the most part, you can walk through it by reviewing the jobs outlined in `.circleci/config.yml`.

1. First, your push to Github triggers CircleCI to checkout your latest code for the branch in question.
2. Once it does, it creates a workspace where it does an NPM install, and then it caches it for reuse. These are pretty standard steps that you might see in other samples.
3. It runs a series of unit tests (in this case, a few dead simple ones using the test runner [ava](https://github.com/avajs/ava) just to illustrate a typical workflow).
4. If the tests pass (they always do, right?! :D), it does a deploy to Now. I'll run through what it is doing in this step next.

## The deploy job that makes it all work

1. The first thing the deploy job does is it installs the Now Cli.

`sudo npm install --global --unsafe-perm now`

This wasn't my brilliance, but something I found in other samples online (I'll try to dig up the link).

2. Next, and depending on the branch name, two commands are run. A `now` deploy is done using the relevant `now.json`, followed by a `now alias`.

## Some notes and other useful info

* If you have a team setup in Now, you can added it to each command in the deploy job like so

`now --token $ZEIT_TOKEN --team youteam --local-config .now/now.production.json`

* In the deploy job, you will see references to `${CIRCLE_BRANCH}`. This token is automatically made available by CircleCI.
* I have specifically aliased my branches as subdomains of my main URL in the now.josn files. You can do whatever suits your project.
* The Now configuration used for this repo is of the deployment type Node.js. It is a simple express app after all. It should work fine with Docker if that's how you role.

## Questions and Comments

Please send me any questions or comments. I can be reached on [Gitub](https://github.com/niccai) or [Twitter](https://twitter.com/niccai).
