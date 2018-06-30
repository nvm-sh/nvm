import requests


class EoBot:
    """ EOBot API Access built with Requests for Python 2.7 """

    def __init__(self, email, password):
        """ The module requires an email and password for EoBot to function, and will automatically lookup and store
            the user ID for use in future requests """
        self.url_base = "https://www.eobot.com/api.aspx?"
        self.email = str(email)
        self.password = str(password)
        self.debug = 0
        url = self.url_base + 'email=' + self.email + '&password=' + self.password
        self.user_id = (requests.get(url, timeout=5)).text
        self.timeout = 5

    def set_debug(self, mode):
        """ Set the debug mode, defaults to 0
            Setting 1 will force functions to print URLs """
        if mode == 1:
            self.debug = 1
            print "Debug Mode enabled"
            return "Success"
        if mode == 0:
            self.debug = 0
            print "Debug Mode disabled"
            return "Success"
        else:
            return "Error or not implemented"

    def get_userid(self):
        """ Returns the User ID from the inital object creation, useful for debugging """
        return self.user_id

    def get_coin_value(self, coin):
        """ Return the current value for a Coin, expects the EoBot coin ID string """
        url = self.url_base + 'coin=' + str(coin)
        
        if self.debug == 1:
            print url

        try:
            result = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as exception:
            print exception
            return "ERROR"

        return float(result.text)

    def get_email(self):
        """ Return set email, shouldn't need this, maybe for debugging """
        return self.email

    def get_paswrd(self):
        """ Return set password, shouldn't need this, maybe for debugging """
        return self.password

    def get_mining_coin(self):
        """ Returns the currently mining coin for the user account """
        url = self.url_base + "idmining=" + self.user_id

        if self.debug == 1:
            print url

        try:
            coin = (requests.get(url, timeout=self.timeout)).text
        except requests.exceptions.RequestException as exception:
            print exception
            return "ERROR"

        return coin

    def get_all_balances(self):
        """ Returns an dict containing all values """
        url = self.url_base + "total=" + self.user_id

        if self.debug == 1:
            print url

        try:
            balance_raw = (requests.get(url)).text
        except requests.exceptions.RequestException as exception:
            print exception
            return "ERROR"

        balance = {}

        for line in balance_raw.split(';'):
            if self.debug == 1:
                print line

            if ':' in line:
                line_array = line.split(':')
                balance[line_array[0]] = line_array[1]

        return balance

    def get_coin_balance(self, coin):
        """ Returns a specific coin balance for your account, requires a EoBot Coin String """
        totals = self.get_all_balances()
        if coin in totals.keys():
            if self.debug == 1:
                print coin

            return float(totals[coin])
        else:
            return 'Bad Coin'

    def get_all_speeds(self):
        """ Returns a dict with all mining speeds """
        url = self.url_base + "idspeed=" + self.user_id

        if self.debug == 1:
            print url

        try:
            speed_raw = (requests.get(url, timeout=self.timeout)).text
        except requests.exceptions.RequestException as exception:
            print exception
            return "ERROR"

        speed = {}

        for line in speed_raw.split(';'):
            if self.debug == 1:
                print line

            if ':' in line:
                line_array = line.split(':')
                speed[line_array[0]] = line_array[1]

        return speed

    def get_one_speed(self, m_type):
        """ Returns a specific mining speed, requires a EoBot mining type string """
        speeds = self.get_all_speeds()
        if m_type in speeds.keys():
            if self.debug == 1:
                print m_type

            return speeds[m_type]
        else:
            return 'Bad Mining Type'

    def set_mining_coin(self, coin):
        """ Sets the mining coin on your account, requires a EoBot Coin String
            Will return string Success on success and ERROR if not.
        """
        url = self.url_base + "id=" + self.user_id + "&email=" + self.email + "&password=" + self.password + \
            "&mining=" + coin

        if self.debug == 1:
            print url

        try:
            requests.post(url, timeout=self.timeout)
        except requests.exceptions.RequestException as exception:
            print exception
            return "ERROR"

        if self.get_mining_coin() == coin:
            return "Success"
        else:
            return "Error"

    def get_deposit_address(self, coin):
        """ Returns a desposit wallet address for the EoBot Coin String"""
        url = self.url_base + "id=" + self.user_id + '&deposit=' + str(coin)

        if self.debug == 1:
            print url

        try:
            result = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as exception:
            print exception
            return "ERROR"

        return result.text

    def get_exchange_est(self, convertfrom, convertto, amount):
        """ Returns the estimated result from converting first coin string to the 2nd coin string,
            in the amount given """
        url = self.url_base + 'exchangefee=true&convertfrom=' + convertfrom + '&amount=' +str(amount) + '&convertto=' \
            + convertto

        if self.debug == 1:
            print url

        try:
            result = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as exception:
            print exception
            return "ERROR"

        return result.text

    def exchange_currency(self, convertfrom, convertto, amount):
        """ Returns the estimated result from converting first coin string to the 2nd coin string,
            in the amount given """
        url = self.url_base + 'id=' + self.user_id + '&email=' + self.email + '&password=' + self.password + \
            '&convertfrom=' + convertfrom + '&amount=' + str(amount) + '&convertto=' + convertto

        if self.debug == 1:
            print url

        try:
            result = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as exception:
            print exception
            return "ERROR"

        return result.text

    def withdraw_currency(self, coin, amount, wallet):
        """ Withdraw currency from the specified coin string, in the specified amount, to the specified wallet """

        url = self.url_base + 'id=' + self.user_id + '&email=' + self.email + '&password=' + self.password + \
            '&manualwithdraw=' + coin + '&amount=' + str(amount) + '&wallet=' + wallet

        if self.debug == 1:
            print url

        try:
            result = requests.get(url, timeout=self.timeout)
        except requests.exceptions.RequestException as exception:
            print exception
            return "ERROR"

        return result.text
