## Slide Templates {#slide-templates .hero-slide}

:::::::::: hero-grid
:::::::: hero-left
![University of Exeter logo](uoe-logo.png){.hero-uoe}

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
![QR code](docs-qr.png)

[Link text](https://example.com)
:::

::: presenter-line
Presenter name - Team/Unit - Date
:::

![GW4 logo](gw4-logo.png){.hero-gw4}
::::::::

::: hero-right
![Hero image](isambard-exterior.jpeg)
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
![Optional image (Image caption here)](isambard-exterior.jpeg)
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
![QR code](docs-qr.png)

Call-to-action text
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
![Background image](isambard-exterior.jpeg){.low-density}

::: pi-line
PI: Dr. Name --- Institution
:::

::: panel
[Case study title]{.panel-title}

Description paragraph one explaining the research and its context.

Description paragraph two with results or impact.
:::

![Detail image](machine-room.jpeg){.high-density}

::: {.label .low}
Low-density label
:::

::: {.label .high}
High-density label
:::
:::::::
