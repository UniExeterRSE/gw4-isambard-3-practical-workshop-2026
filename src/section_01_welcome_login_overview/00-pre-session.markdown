## Getting set up before we start {#pre-session-arrival .hero-slide}

:::::::::: hero-grid
:::::::: hero-left
![](../assets/uoe-logo.png){.hero-uoe alt="University of Exeter logo"}

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
![[This
page](https://uniexeterrse.github.io/gw4-isambard-3-practical-workshop-2026/section_01_welcome_login_overview/00-pre-session.html)](../assets/pre-session-qr.png){alt="Pre-session QR code"}
:::

::: presenter-line
If setup is already complete: grab a coffee and check you can open a terminal and reach the login node.
:::

![](../assets/gw4-logo.png){.hero-gw4 alt="GW4 logo"}
::::::::

::: hero-right
![](../assets/isambard-exterior.jpeg){alt="Isambard 3 exterior"}
:::
::::::::::

::: notes
This slide is displayed on-screen continuously from 09:30 to 10:00 while helpers circulate. No presenter monologue
required --- the slide is self-serve. Suggested welcome line as the room fills: "Welcome --- if you haven't finished the
setup steps on screen, work through them now; helpers are circulating."
:::

## Step 1: Initial account setup {#initial-setup .shell-slide}

::: slide-subtitle
<https://docs.isambard.ac.uk/user-documentation/tutorials/setup/>
:::

::::::: shell-grid
:::::: shell-text
::::: columns
::: {.column width="55%"}
1.  Go to <https://portal.isambard.ac.uk/>
2.  Sign in: **University Login (MyAccessID)** → **University of Exeter** → your Exeter credentials
3.  Follow on-screen instructions --- accept the acceptable-use policy and the workshop project invitation
4.  Choose a UNIX username:\
    <https://docs.isambard.ac.uk/user-documentation/tutorials/setup/#how-to-set-your-unix-username>

**If these notes are too brief** --- follow the full instructions at the link above.
:::

::: {.column width="45%"}
**The Isambard 3 portal**

<https://portal.isambard.ac.uk>

Simple project dashboard:

- **User dashboard** --- lists projects you belong to
- **Click a project** --- shows compute usage and NHR (Node Hours Remaining)

Workshop project:\
[`exeter-workshop-260421`](https://portal.isambard.ac.uk/projects/b79459a0c1414c40b6ffaebfe827b726/)

Project alias: **`e6c`** (used in SSH host aliases)
:::
:::::
::::::
:::::::

::: notes
Pre-workshop setup Step 1. You will receive a project invitation --- accept it during this step. The right column is a
brief portal orientation; attendees will have already logged in here. Do not spend more than a minute on the portal side
at the workshop; see README "Out of Scope".
:::

## Step 2: Clifton and SSH access {#login-start .shell-slide}

::: slide-subtitle
<https://docs.isambard.ac.uk/user-documentation/guides/login/>
:::

::::::: shell-grid
:::::: shell-text
::::: columns
::: {.column width="55%"}
**Install Clifton on macOS/Linux:**

``` bash
bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026/refs/heads/main/bootstrap/install/clifton.sh) install
```

Then authenticate and connect:

``` bash
clifton auth
```

Authenticate in the browser. Clifton will then suggest:

``` console
You may now want to run `clifton ssh-config write` to configure your SSH config aliases.
```

Run it, then SSH in:

``` bash
ssh e6c.3.isambard
```
:::

::: {.column width="45%"}
Using Windows? Follow the [official guide](https://docs.isambard.ac.uk/user-documentation/guides/login/)

Issues? [Open a ticket](https://support.isambard.ac.uk/)

Example `clifton auth` output:

``` console
Successfully authenticated as **@exeter.ac.uk and downloaded SSH certificate for projects:
- e6c
Certificate valid for 11 hours and 59 minutes.

Available SSH host aliases:
 - e6c.macs3.isambard
 - e6c.3.isambard
```
:::
:::::
::::::
:::::::

::: notes
Pre-workshop Step 2. Attendees should already have Clifton installed before arriving; the install command is shown for
reference. In-session spoken cue: "Everyone open a terminal now --- we will run `clifton auth` together." Helpers watch
for: clifton auth failures, SSH key issues, and proxy errors. After roughly two minutes, do a show-of-hands check that
everyone is connected. If several people are stuck, pause briefly; if only one or two are stuck, helpers handle it while
the presenter moves on.
:::

## Step 3: VS Code CLI {#vscode-setup .shell-slide}

::: slide-subtitle
<https://docs.isambard.ac.uk/user-documentation/guides/vscode/#install-vs-code-cli>
:::

:::: shell-grid
::: shell-text
**Install the VS Code CLI** on Isambard 3 (do this once, before the workshop):

``` bash
bash <(curl -L https://raw.githubusercontent.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026/refs/heads/main/bootstrap/install/code.sh) install
```

**Launch a browser tunnel** (run this each session from the login node):

``` bash
code tunnel --name isambard3
```

Follow the on-screen instructions to authenticate. When you see:

``` console
Open this link in your browser: https://vscode.dev/tunnel/isambard3/...
```

Copy that URL and open it in a browser tab. You now have a working editor connected to Isambard 3.

------------------------------------------------------------------------------------------------------------------------

**Fallback** --- if the VS Code CLI is unavailable, load Emacs instead:

``` bash
module load brics/emacs
```

**Prefer another editor?** Desktop VS Code, vim, nano all work --- bring it set up. We will not troubleshoot alternative
editors during the session.
:::
::::

::: notes
Pre-workshop Step 3. The install command is for before the workshop. In-session spoken cue: "If you installed the VS
Code CLI during pre-workshop setup, run `code tunnel --name isambard3` now and open the URL it shows you in a browser
tab. If you prefer another editor, use that --- just have it ready." Keep this to under a minute; attendees who followed
the pre-workshop email will already have this ready.
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
