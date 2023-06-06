# Fire Weather Forecast

This script is licensed under the GPL 3.0 and may be modified and shared provided the original author is credited by leaving the footer.html file as-is.  ***There is NO support for this repo.***

## Docker setup
1. Create a file in your user folder called `env.txt` to contain settings.  This should include the password to use for SSH access to the server.

**NEVER COMMIT THIS FILE TO A REPOSITORY!**
It should sit well outside the project folder.

```
APPLICATION_ENV=local
DEVELOPER_ENV=smmitchell
```

Application Environment can be one of `local`, `development` or `production`.
Developer environment should reflect your own name.

2. Build the docker container.

```bash
cd project_folder
docker-compose --env-file <PATH TO YOUR .ENV FILE> build --progress=plain
```

A secure random root password will be generated during the build.
Keep a safe record of this password but **NEVER** include it in the repository!
You will need this password to obtain root ssh access to the container.
During the build you will see the generated password displayed:

```bash
#11 0.306 ================================================================================
#11 0.307 ================================================================================
#11 0.307
#11 0.307 Container's root password follows
#11 0.307
#11 0.307 PLEASE NOTE THIS VALUE - DO NOT INCLUDE IT ANYWHERE IN YOUR REPO
#11 0.307
#11 0.307 abcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabcabca
#11 0.307
#11 0.307 ================================================================================
#11 0.308 ================================================================================
#
```

## Running the container

1. Have docker bring the container up.

```bash
cd project_folder
docker-compose --env-file <PATH TO YOUR .ENV FILE> up -d
```

2. If you have Docker Desktop you should now see the container installed and ready to use.

## Completing website install

1. Open an ssh terminal connection to the new container and execute the following:

```bash
cd /var/www
composer install
```

## Project specific instructions

1. Adjust any database specific connections in the `config/autoload/global.php` file.
2. FIXME:  Add any additional steps needed to get containers running.

## Unit Tests

The template is designed to use PHPUnit testing.

1. Open an ssh terminal connection to the new container and execute the following:

```bash
$ cd /var/www
$ ./vendor/bin/phpunit
```

## Legacy Installation

### Take the time to read the WARRANTY file.

**DO NOT USE THIS SOFTWARE FOR CRITICAL OR LIFE-SAFETY FUNCTIONS OR DECISIONS!**

It is currently in use by the [Saint David Fire Distict](http://www.stdavidfire.com/firewx).

>This script requires python3, the [wxcast](https://github.com/smarlowucf/wxcast) Python3 library, ruby, [jekyll](https://jekyllrb.com/docs/), [sed](https://www.gnu.org/software/sed/manual/sed.html), [tr](https://linuxize.com/post/linux-tr-command/), [awk](https://www.gnu.org/software/gawk/manual/), [cut](https://www.computerhope.com/unix/ucut.htm), [wget](https://www.gnu.org/software/wget/manual/), [grep](https://www.gnu.org/software/grep/manual/) and requires some configuration and the use of [crontab](https://www.tutorialspoint.com/unix_commands/crontab.htm) and the mail commands.  Before trying to use this repo, you should become VERY familiar with jekyll, sed cut, awk and tr.

DIFFICULTY LEVEL: **MODERATE**

11/30/2020: I've started a rudimentary configuration program to help with setting things up, confirming required system programs
are installed, confirming the required build system is installed, confirming whether wxcast is installed and then saving configuration
strings to the appropriate files.  I've attempted to set things up so that it will attempt to install python3, ruby, bundler, gcc and make
for Redhat and Debian/Ubuntu systems.  An attempt to install wxcast is also included. **BEFORE RUNNING ANY OF THE SHELL SCRIPTS, MAKE
SURE YOU LOOK OVER THE SCRIPT.  NEVER BLINDLY RUN A SHELL SCRIPT WITHOUT REVIEWING IT.**


1. Install ruby using your package manager (sudo [package manager name] install python3 ruby bundler gcc make).
2. Install jekyll (sudo gem install jekyll).
3. Run bundler (sudo bundle install)
4. Install wxcast and dependencies (sudo pip3 install -r requirements.txt).
5. Set the required variables in the config file.
6. Set the required variables in the index.md file.
7. Copy your department's logo to the images directory.
8. Use crontab -e to set the frequency that weather.sh will be ran.  It is recommended to run it at least every hour.
9. Use crontab -e to set how often to run send-mail.sh.
   I send it out once per day.

**SOME ASSEMBLY REQUIRED:**
To make the script usable for you, you're going to need to do some research as to URLS for the fire danger, preparedness levels and the prescribed burns.  You're also going to have tinker with formatting the wxcast output for your specific area.  Little did I know that the data entered for each report type is NOT necessarily standard across NWS offices.

**For some reason, the NWS has issues with their 7-day forecast feed that causes a "No forecast found" message
to be sometimes be returned.  This is a KNOWN issue and the NWS has no plans to fix it.**
