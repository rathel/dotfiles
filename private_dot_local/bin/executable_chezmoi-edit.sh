#!/bin/env bash

chezmoi managed -p absolute \
	| sk -p "What file would you like to edit?" \
	| xargs -I {} chezmoi edit {}
