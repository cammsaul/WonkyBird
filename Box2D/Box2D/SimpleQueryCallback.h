//
//  SimpleQueryCallback.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 Cam Saul. All rights reserved.
//

#ifndef __WonkyBird__SimpleQueryCallback__
#define __WonkyBird__SimpleQueryCallback__

#include <functional>
#include <Box2D/Box2D.h>

class SimpleQueryCallback : public b2QueryCallback {
public:
	using SuccessFnT = std::function<void(b2Fixture *)>;
	SimpleQueryCallback(const b2Vec2& pointToTest, const SuccessFnT& successFn = SuccessFnT{}); ///< pointToTest is the point to check each object's aabb against
	
	virtual bool ReportFixture(b2Fixture* fixture) override;
	
	b2Fixture* FoundFixture() const { return foundFixture_; }
private:
	b2Vec2 pointToTest_;
	b2Fixture* foundFixture_;
	SuccessFnT successFn_;
};

#endif /* defined(__WonkyBird__SimpleQueryCallback__) */
