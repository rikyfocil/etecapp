from django.test import TestCase, Client
from time import time


class UrlTest(TestCase):
    def setUp(self):
        self.c = Client()

    # Right
    def testUrls(self):
        response = self.c.get('/')

        self.assertEquals('/login/?next=/', response.url)

    # Boundaries - no boundaries here

    # Inverse relations - already tested in testUrls

    # Cross-check - no algorithm to cross-check

    # Errors - no error conditions that are not tested with cross-check

    # Performance
    def testUrlPerformance(self):
        inicio = time()
        self.c.get('/')
        fin = time()

        self.assertLess(fin - inicio, 2)
