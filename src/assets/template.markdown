## Slide Templates {#slide-templates .hero-slide}

:::::::::: hero-grid
:::::::: hero-left
![](uoe-logo.png){.hero-uoe alt="University of Exeter logo"}

::: hero-title
Presentation Title Here
:::

::: hero-subtitle
Subtitle text --- one or two lines\
describing the presentation
:::

::: next-steps-card
[Resources]{.card-title}

- [Link one](https://example.com)
- Help: `support@example.com`
:::

::: docs-qr-block
![[Link text](https://example.com)](docs-qr.png){alt="QR code"}
:::

::: presenter-line
Presenter name - Team/Unit - Date
:::

![](gw4-logo.png){.hero-gw4 alt="GW4 logo"}
::::::::

::: hero-right
![](isambard-exterior.jpeg){alt="Hero image"}
:::
::::::::::

::: notes
- These notes are not shown on slides --- they appear in speaker view
- Use this section at the end of any `.md` file for presenter guidance
:::

## TEMPLATE: Plain slide

This is a default pandoc revealjs slide. No special class is needed.

- Bullet one

- Bullet two

- Bullet three

    Column A   Column B
    ---------- ----------
    Data       Data

## TEMPLATE: Plain slide with columns

::::: columns
::: {.column width="50%"}
Left column content goes here.

- Item one
- Item two
:::

::: {.column width="50%"}
Right column content goes here.

- Item three
- Item four
:::
:::::

## TEMPLATE: Text and image grid with subheadings {#template-text-and-image-grid-with-subheadings .shell-slide}

::: slide-subtitle
Optional subtitle line
:::

::::: shell-grid
::: shell-text
### First topic

Description of the first topic.

### Second topic

Description of the second topic.

  Key     Value
  ------- -------
  Row 1   Data
  Row 2   Data
:::

::: grid-image
![Image caption here](isambard-exterior.jpeg){alt="Alt text here"}
:::
:::::

## TEMPLATE: Fit panels (good / bad) {#template-fit-panels-good-bad .shell-slide}

::::: fit-panels
::: {.fit-panel .good}
[Good heading]{.fit-title}

- Positive point one
- Positive point two
- Positive point three
:::

::: {.fit-panel .bad}
[Bad heading]{.fit-title}

- Negative point one
- Negative point two
- Negative point three
:::
:::::

::: slide-note
Optional footnote text below the panels.
:::

## TEMPLATE: Flow row --- 3 steps {#template-flow-row-3-steps .shell-slide}

:::::: flow-row
::: flow-card
[Step 1]{.flow-title}

Description of the first step.
:::

::: flow-card
[Step 2]{.flow-title}

Description of the second step.
:::

::: flow-card
[Step 3]{.flow-title}

Description of the third step.
:::
::::::

::: slide-note
Optional note below the flow row.
:::

## TEMPLATE: Flow row --- 5 steps {#template-flow-row-5-steps .shell-slide}

:::::::: flow-row
::: flow-card
[Step 1]{.flow-title}

First.
:::

::: flow-card
[Step 2]{.flow-title}

Second.
:::

::: flow-card
[Step 3]{.flow-title}

Third.
:::

::: flow-card
[Step 4]{.flow-title}

Fourth.
:::

::: flow-card
[Step 5]{.flow-title}

Fifth.
:::
::::::::

## TEMPLATE: Contact grid {#template-contact-grid .shell-slide}

::::: contact-grid
::: contact-card
Workshop helpers are circulating --- raise a hand any time.

After the workshop: `support@example.com`

Docs: <https://example.com>
:::

::: cta-card
![Call-to-action text](docs-qr.png){alt="QR code to doc"}
:::
:::::

## TEMPLATE: Discussion slide {#template-discussion-slide .qa-slide}

::: qa-mark
Discussion
:::

::: qa-subtitle
Optional prompt line --- e.g. "Questions? Comments? Anything you found interesting?"
:::

## TEMPLATE: Case study {#template-case-study .case-study-slide}

::::::: case-study-wrap
![](isambard-exterior.jpeg){.low-density alt="Background image"}

::: pi-line
PI: Dr. Name --- Institution
:::

::: panel
[Case study title]{.panel-title}

Description paragraph one explaining the research and its context.

Description paragraph two with results or impact.
:::

![](machine-room.jpeg){.high-density alt="Detail image"}

::: {.label .low}
Low-density label
:::

::: {.label .high}
High-density label
:::
:::::::
