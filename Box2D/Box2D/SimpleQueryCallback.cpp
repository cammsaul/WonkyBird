//
//  SimpleQueryCallback.cpp
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 Cam Saul. All rights reserved.
//

#include "SimpleQueryCallback.h"

SimpleQueryCallback::SimpleQueryCallback(const b2Vec2& point, const SuccessFnT& successFn):
	pointToTest_	{ point },
	foundFixture_	{ nullptr },
	successFn_		{ successFn}
{}

bool SimpleQueryCallback::ReportFixture(b2Fixture* fixture) {
	const b2Body* body = fixture->GetBody();
	if (body->GetType() == b2_dynamicBody) {
		if (fixture->TestPoint(pointToTest_)) {
			foundFixture_ = fixture;
			if (successFn_) successFn_(fixture);
			return false; // terminate the query
		}
	}
	return true; // continue the query
}