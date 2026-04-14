## Getting set up before we start {#pre-session-arrival .shell-slide}

::: slide-subtitle
Doors open 09:30 --- workshop teaching starts at 10:00
:::

:::: shell-grid
::: shell-text
If you have not yet completed the pre-workshop setup, please work through these steps now. Helpers are circulating ---
raise a hand if anything is not working.

1.  **Initial account setup**

    <https://docs.isambard.ac.uk/user-documentation/tutorials/setup/>

2.  **Clifton / SSH access**

    <https://docs.isambard.ac.uk/user-documentation/guides/login/>

3.  **VS Code CLI** (install the CLI and launch VS Code in the browser)

    <https://docs.isambard.ac.uk/user-documentation/guides/vscode/#install-vs-code-cli>

If you completed setup before arriving: grab a coffee and check you can open a terminal and reach the login node.
:::
::::

::: notes
This slide is displayed on-screen continuously from 09:30 to 10:00 while helpers circulate. No presenter monologue
required --- the slide is self-serve. TODO: add a brief spoken welcome line for when the room starts filling up.
:::

## Isambard 3 portal {#portal .shell-slide}

::: slide-subtitle
Account balance and project membership at a glance
:::

:::: shell-grid
::: shell-text
TODO: add image of the portal

The portal shows two things:

- Your **project membership**
- Your **account balance**

You do not need the portal for anything hands-on in this workshop. We mention it so you know it exists.

Portal URL: <https://portal.isambard.ac.uk>
:::
::::

::: notes
One slide only --- do not spend more than a minute here. The portal is not a teaching goal for this session; see README
"Out of Scope".
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
TODO: add exact presenter wording for the Clifton login start cue. Suggested prompt: "Everyone open a terminal now ---
we will run clifton auth together." Helper choreography: TODO: confirm what helpers should watch for (clifton auth
failures, SSH key issues, proxy errors). After roughly two minutes, do a show-of-hands check that the room is in.
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
TODO: add exact VS Code tunnel launch command from docs
```

Then open the URL shown in your terminal in a browser tab.

**Using a different editor?** Desktop VS Code, vim, nano, and others all work --- just bring them set up. We will not
troubleshoot alternative editors during the session.
:::
::::

::: notes
TODO: add the exact spoken signpost line to say live in the room. Confirm the VS Code CLI launch command from
<https://docs.isambard.ac.uk/user-documentation/guides/vscode/#install-vs-code-cli> and fill in the code block above.
Keep this brief --- one minute at most. Attendees who followed the pre-workshop email will already have this ready.
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
TODO: confirm the exact fallback support route (helpdesk ticket vs. reply-to email vs. in-room helper). This slide is a
contingency --- only show it if someone in the room is stuck and the rest of the group needs to move on. Do not read it
out as part of the normal flow.
:::
