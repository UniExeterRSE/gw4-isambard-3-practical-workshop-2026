## Getting set up before we start {#pre-session-arrival .hero-slide}

:::::::::: hero-grid
:::::::: hero-left
![University of Exeter logo](../assets/uoe-logo.png){.hero-uoe}

::: hero-title
Getting set up before we start
:::

::: hero-subtitle
Doors open 09:30 --- workshop teaching starts at 10:00
:::

::: next-steps-card
[Pre-workshop setup]{.card-title}

- [Initial account setup](https://docs.isambard.ac.uk/user-documentation/tutorials/setup/)
- [Clifton / SSH access](https://docs.isambard.ac.uk/user-documentation/guides/login/)
- [VS Code CLI](https://docs.isambard.ac.uk/user-documentation/guides/vscode/#install-vs-code-cli)
:::

::: docs-qr-block
![Pre-session QR code](../assets/pre-session-qr.png)

[This
page](https://uniexeterrse.github.io/gw4-isambard-3-practical-workshop-2026/section_01_welcome_login_overview/00-pre-session.html)
:::

::: presenter-line
If setup is already complete: grab a coffee and check you can open a terminal and reach the login node.
:::

![GW4 logo](../assets/gw4-logo.png){.hero-gw4}
::::::::

::: hero-right
![Isambard 3 exterior](../assets/isambard-exterior.jpeg)
:::
::::::::::

::: notes
This slide is displayed on-screen continuously from 09:30 to 10:00 while helpers circulate. No presenter monologue
required --- the slide is self-serve. Suggested welcome line as the room fills: "Welcome --- if you haven't finished the
setup steps on screen, work through them now; helpers are circulating."
:::

## Isambard 3 portal {#portal .shell-slide}

::: slide-subtitle
You have already seen this --- a quick orientation
:::

:::: shell-grid
::: shell-text
<https://portal.isambard.ac.uk>

You already logged in here during pre-workshop setup (Step 1 of the setup tutorial).

The portal is a simple **project dashboard**:

- **User dashboard** --- lists the projects you belong to. For most of you, that is one: the workshop project.
- **Click into a project** --- shows compute usage and NHR (Node Hours Remaining) for that project.

Nothing hands-on here --- we mention it so you know where to look later.
:::
::::

::: notes
One slide only --- do not spend more than a minute here. Attendees logged in to the portal in Step 1 of the pre-workshop
setup tutorial, so this is a quick recap, not new material. The portal is not a teaching goal for this session; see
README "Out of Scope".
:::

## Logging in: Clifton and SSH {#login-start .shell-slide}

::: slide-subtitle
Starting the login process together
:::

:::: shell-grid
::: shell-text
Open a terminal and run:

``` bash
clifton auth
```

Then SSH in:

``` bash
ssh <username>@login.isambard.ac.uk
```

Helpers are circulating --- raise a hand if you see an error.
:::
::::

::: notes
Spoken cue: "Everyone open a terminal now --- we will run clifton auth together." Helpers watch for: clifton auth
failures, SSH key issues, and proxy errors. After roughly two minutes, do a show-of-hands check that the room is in. If
several people are stuck, pause briefly; if it is one or two, helpers handle it while the presenter moves on.
:::

## Editing files: VS Code in the browser {#vscode-signpost .shell-slide}

::: slide-subtitle
The taught editor path for this workshop
:::

:::: shell-grid
::: shell-text
This workshop uses **VS Code via the browser-based tunnel** as the standard editor.

If you installed the VS Code CLI during setup, launch it now:

``` bash
code tunnel --name isambard3
```

Then open the URL shown in your terminal in a browser tab.

**Using a different editor?** Desktop VS Code, vim, nano, and others all work --- just bring them set up. We will not
troubleshoot alternative editors during the session.
:::
::::

::: notes
Spoken cue: "If you installed the VS Code CLI during pre-workshop setup, run `code tunnel --name isambard3` now and open
the URL it shows you in a browser tab. If you prefer another editor, use that --- just have it ready." Keep this to
under a minute; attendees who followed the pre-workshop email will already have this ready.
:::

## If you cannot log in {#follow-along-contingency .shell-slide}

::: slide-subtitle
Passive follow-along for the rare attendee with an access problem
:::

:::: shell-grid
::: shell-text
If you are still having trouble connecting after the 09:30 setup window:

- **Follow along on the projected screen** for now --- you will still get value from watching the workflow.
- **Flag it to a helper** so we can try to diagnose the issue during a break.
- **Reply to the pre-workshop email** if the project invitation never arrived --- we can investigate after the session.

Access issues on the day are rare if the pre-workshop steps were completed. Do not let it derail the room.
:::
::::

::: notes
Fallback support route: in-room helper first; reply to the pre-workshop email for project-invitation issues that cannot
be resolved on the day. Only show this slide if someone is still stuck when the room needs to move on. Do not read it
out as part of the normal flow.
:::
