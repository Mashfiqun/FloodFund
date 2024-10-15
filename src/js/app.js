App = {
  webProvider: null,
  contracts: {},
  account: '0x0',

  initWeb: function() {
    const provider = window.ethereum;
    if (provider) {
      App.webProvider = provider;
    } else {
      $("#loader-msg").html('No MetaMask Ethereum provider found');
      App.webProvider = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
    }

    return App.initContract();
  },

  initContract: function() {
    $.getJSON("FloodFund.json", function(floodFund) {
      App.contracts.FloodFund = TruffleContract(floodFund);

      App.contracts.FloodFund.setProvider(App.webProvider);

      return App.render();
    });
  },

  render: async function() {
    const loader = $("#loader");
    const content = $("#content");

    loader.show();
    content.hide();

    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        App.account = accounts[0];
        $("#accountAddress").html(`Connected account: ${App.account}`);
      } catch (error) {
        if (error.code === 4001) {
          console.warn('User rejected request');
        }
        $("#accountAddress").html("Account: Not Connected");
        console.error(error);
      }
    }

    loader.hide();
    content.show();
  },

  registerDonor: async function() {
    const contractInstance = await App.contracts.FloodFund.deployed();
    const name = $("#donorName").val();
    const mobileNumber = $("#donorMobile").val();

    try {
      await contractInstance.registerDonor(name, mobileNumber, { from: App.account });
      alert("Registration successful");
    } catch (error) {
      console.error(error);
      alert("Registration failed");
    }
  },

  donate: async function() {
    const contractInstance = await App.contracts.FloodFund.deployed();
    const mobileNumber = $("#donorMobileDonation").val();
    const area = $("#donationArea").val();
    const amount = $("#donationAmount").val() * 1000000000000000000;

    try {
      await contractInstance.donate(area, mobileNumber, { from: App.account, value: amount });
      alert("Donation successful");
    } catch (error) {
      console.error(error);
      alert("Donation failed");
    }
  },

  checkDonorInfo: async function() {
    const contractInstance = await App.contracts.FloodFund.deployed();
    const donorAddress = $("#donorAddress").val();

    try {
      const donorInfo = await contractInstance.getDonorInfoByAddress(donorAddress);
      $("#donorInfo").html(`Name: ${donorInfo[0]}<br>Phone Number: ${donorInfo[1]}`);
    } catch (error) {
      console.error(error);
      $("#donorInfo").html("Donor info not found");
    }
  },

  getTotalFunds: async function() {
    const contractInstance = await App.contracts.FloodFund.deployed();

    try {
      const balance = await contractInstance.showTotal();
      $("#fundsDisplay").html(
        `${balance[0]}: ${balance[1]/1000000000000000000} ETH<br>` +
        `${balance[2]}: ${balance[3]/1000000000000000000} ETH<br>` +
        `${balance[4]}: ${balance[5]/1000000000000000000} ETH<br>` +
        `${balance[6]}: ${balance[7]/1000000000000000000} ETH<br>`
      );
    } catch (error) {
      console.error(error);
      $("#fundsDisplay").html("Failed to retrieve total donations");
    }
  },
};

$(function() {
  $(window).load(function() {
    App.initWeb();
  });
});
