--サブテラーの戦士
function c16719140.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16719140,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,16719140)
	e1:SetCost(c16719140.spcost)
	e1:SetTarget(c16719140.sptg1)
	e1:SetOperation(c16719140.spop1)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16719140,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FLIP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,16719141)
	e2:SetCondition(c16719140.spcon)
	e2:SetTarget(c16719140.sptg2)
	e2:SetOperation(c16719140.spop2)
	c:RegisterEffect(e2)
	if not c16719140.global_check then
		c16719140.global_check=true
		c16719140[0]=Group.CreateGroup()
		c16719140[0]:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetCode(EVENT_FLIP)
		ge1:SetOperation(c16719140.regop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_BATTLED)
		ge2:SetOperation(c16719140.trigop)
		Duel.RegisterEffect(ge2,0)
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_ATTACK_DISABLED)
		ge3:SetOperation(c16719140.clearop)
		Duel.RegisterEffect(ge3,0)
		c16719140[1]=ge2
	end
end
function c16719140.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c16719140.costfilter(c,e,tp,mg,rlv)
	if not (c:IsLevelAbove(0) and c:IsSetCard(0xed) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN))) then return false end
	local lv=c:GetLevel()-rlv
	return mg:GetCount()>0 and (lv<=0 or mg:CheckWithSumGreater(Card.GetOriginalLevel,lv))
end
function c16719140.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetReleaseGroup(tp):Filter(Card.IsLevelAbove,nil,1)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if not mg:IsContains(c) then return false end
		mg:RemoveCard(c)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
			and Duel.IsExistingMatchingCard(c16719140.costfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mg,c:GetOriginalLevel())
	end
	e:SetLabel(0)
	mg:RemoveCard(c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c16719140.costfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mg,c:GetOriginalLevel())
	Duel.SendtoGrave(g,REASON_COST)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c16719140.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<-1 then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local mg=Duel.GetReleaseGroup(tp):Filter(Card.IsLevelAbove,nil,1)
	if not mg:IsContains(c) then return end
	mg:RemoveCard(c)
	if mg:GetCount()==0 then return end
	local spos=0
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then spos=spos+POS_FACEUP_DEFENSE end
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN) then spos=spos+POS_FACEDOWN_DEFENSE end
	if spos~=0 then
		local lv=tc:GetLevel()-c:GetOriginalLevel()
		local g=Group.CreateGroup()
		if lv<=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			g=mg:Select(tp,1,1,nil)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			g=mg:SelectWithSumGreater(tp,Card.GetOriginalLevel,lv)
		end
		g:AddCard(c)
		if g:GetCount()>=2 and Duel.Release(g,REASON_EFFECT)~=0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,spos)
		end
	end
end
function c16719140.cfilter(c,tp)
	return c:IsSetCard(0x10ed) and c:IsControler(tp)
end
function c16719140.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16719140.cfilter,1,nil,tp) and (not Duel.GetAttacker() or re==c16719140[1])
end
function c16719140.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c16719140.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c16719140.regop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetAttacker() then return end
	c16719140[0]:Merge(eg)
end
function c16719140.trigop(e,tp,eg,ep,ev,re,r,rp)
	local g=c16719140[0]:Clone()
	Duel.RaiseEvent(g,EVENT_FLIP,e,0,0,0,0)
	c16719140[0]:Clear()
end
function c16719140.clearop(e,tp,eg,ep,ev,re,r,rp)
	c16719140[0]:Clear()
end
