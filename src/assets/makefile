.PHONY: all	docs-qr workshop-qr pre-session-qr apply-qr clean

all: docs-qr workshop-qr pre-session-qr apply-qr  ## generate all QR codes
docs-qr: docs-qr.png  ## Generate Docs QR code
workshop-qr: workshop-qr.png  ## Generate Workshop QR code
pre-session-qr: pre-session-qr.png  ## Generate Pre-session QR code
apply-qr: apply-qr.png  ## Generate Apply QR code
docs-qr.png:
	qr --output=$@ 'https://docs.isambard.ac.uk'
workshop-qr.png:
	qr --output=$@ 'https://github.com/UniExeterRSE/gw4-isambard-3-practical-workshop-2026/'
pre-session-qr.png:
	qr --output=$@ 'https://uniexeterrse.github.io/gw4-isambard-3-practical-workshop-2026/section_01_welcome_login_overview/00-pre-session.html'
apply-qr.png:
	qr --output=$@ 'https://forms.office.com/e/URU1YTnpq1'

clean:  ## Clean all generated QR code images
	rm -f docs-qr.png workshop-qr.png pre-session-qr.png apply-qr.png

.DEFAULT_GOAL = help
.PHONY: help
help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,parts,":.*##");targets[n]=parts[1];helps[n]=parts[2];l=length(targets[n]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,targets[i]":",helps[i]}' $(MAKEFILE_LIST)
