using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace VehicleQuotes.Test
{
    public class ApiTests
    {
        private readonly HttpClient _httpClient;

        public ApiTests()
        {
            var webAppFactory = new WebApplicationFactory<Program>();
            _httpClient = webAppFactory.CreateDefaultClient();
        }

        [Fact]
        public async Task TestDefaultRoute()
        {
            var response = await _httpClient.GetAsync("/");
            var stringResult = await response.Content.ReadAsStringAsync();

            Assert.Equal(string.Empty, stringResult);
        }

        [Fact]
        public async Task GetBodyTypesTest()
        {
            var response = await _httpClient.GetAsync("/api/BodyTypes");
            var stringResult = await response.Content.ReadAsStringAsync();

            Assert.NotEmpty(stringResult);
        }

        [Fact]
        public async Task GetMakesTest()
        {
            var response = await _httpClient.GetAsync("/api/Makes");
            var stringResult = await response.Content.ReadAsStringAsync();

            Assert.NotEmpty(stringResult);
        }
    }
}