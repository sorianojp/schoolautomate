<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strAction, strInfoIndex)
{
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function checkAll() {
	var maxDisp = document.form_.max_disp.value;
	//unselect if it is unchecked.
	if(!document.form_.selAll.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.fee_'+i+'.checked=false');
	}
	else {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.fee_'+i+'.checked=true');
	}
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.stud_id.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAFeeOptional,enrollment.CourseRequirement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Adivising-Optional Fee","assessment_optional_fee.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","Advising & Scheduling",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														null);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
boolean bolIsTempStud  = false;
Vector vRetResult = null;
Vector vCRStudInfo = null;
Vector vOptionalFeePayable = null;
Vector vOthSetting = null;

CourseRequirement cRequirement = new CourseRequirement();
FAFeeOptional faOptional       = new FAFeeOptional();
boolean bolIsBasic 			   = false;

strTemp = null;
if(WI.fillTextValue("stud_id").length() > 0) 
	strTemp = dbOP.mapUIDToUIndex(request.getParameter("stud_id"));
if(strTemp != null) {
	strTemp = "select course_index from stud_curriculum_hist where user_index = "+strTemp+" and is_valid = 1 and sy_from = "+
					request.getParameter("sy_from")+" and semester = "+request.getParameter("semester");
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null && strTemp.equals("0"))
		bolIsBasic = true;
}
cRequirement.setIsBasic(bolIsBasic);
//faOptional.setIsBasic(bolIsBasic);

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(faOptional.saveOrDelOptionalFee(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = faOptional.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}	
if(WI.fillTextValue("stud_id").length() > 0) {
	vCRStudInfo = cRequirement.getStudInfo(dbOP, request.getParameter("stud_id"),WI.fillTextValue("sy_from"),
											WI.fillTextValue("sy_to"),WI.fillTextValue("semester") );
	if(vCRStudInfo != null) {
		if( ((String)vCRStudInfo.elementAt(10)).compareTo("1") == 0)
			bolIsTempStud = true;

		////////////I have to get here optional fee to be paid.
		vOptionalFeePayable = faOptional.getPossibleOptionalFee(dbOP, (String)vCRStudInfo.elementAt(0), bolIsTempStud, 
								WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"), 
								(String)vCRStudInfo.elementAt(6));
								
		//System.out.println(vOptionalFeePayable);
		vRetResult = faOptional.getOptionalFeePayable(dbOP, (String)vCRStudInfo.elementAt(0), bolIsTempStud, 
								WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
		
		//get here other setting information.
		vOthSetting = faOptional.operateOnAddlAssessementSetting(dbOP, request, 7);
	}
	else 
		strErrMsg = cRequirement.getErrMsg();
}




String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
String[] astrConvertToYr  = {"N/A","1ST YR","2ND YR","3RD YR","4TH YR","5TH YR","6TH YR","7TH YR","","","","","","","",""};

String[] astrConvertPmtMode = {"Full","Installment"};
String[] astrConvertPmtType = {"Cash","Check"};

//String astrConvertToPrepPropStat
%>
<form name="form_" action="./assessment_optional_fee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ASSESSMENT SETTING :: ADDITIONAL OPTIONAL CHARGES ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
</table>
   
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="9%">Student ID</td>
      <td width="32%"><input type="text" name="stud_id" size="20" maxlength="32" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strTemp%>></td>
      <td width="57%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td>
<%
strTemp = request.getParameter("sy_from");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"  
	  onKeyUP="AllowOnlyInteger('form_','sy_from');DisplaySYTo('form_','sy_from','sy_to')">
        to 
<%
strTemp = request.getParameter("sy_to");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
<%
	strTemp = request.getParameter("semester");
	if(strTemp == null) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
%>
        <select name="semester">
<%
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
      <td><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td height="19" colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
<%
if(vCRStudInfo != null && vCRStudInfo.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">Student Name</td>
      <td width="33%"><strong><%=(String)vCRStudInfo.elementAt(1)%></strong></td>
      <td width="47%">ENROLLING STATUS : <font color="#9900FF"><strong> 
        <%
	  if( ((String)vCRStudInfo.elementAt(9)).compareTo("0") ==0){%>
        ENROLLING 
        <%}else{%>
        ENROLLED 
        <%}%>
        </strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course/Major(cy)</td>
      <td colspan="2"><strong>
	  <%if(bolIsBasic){%>
	 	<%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vCRStudInfo.elementAt(6)), false)%>
	  <%}else{%>
		  <%=(String)vCRStudInfo.elementAt(7)%> <%=WI.getStrValue((String)vCRStudInfo.elementAt(8),"/","","")%>
      <%}%>
	  (<%=(String)vCRStudInfo.elementAt(4)%> to <%=(String)vCRStudInfo.elementAt(5)%> )</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>YEAR LEVEL</td>
      <td><strong><%=astrConvertToYr[Integer.parseInt(WI.getStrValue(vCRStudInfo.elementAt(6),"0"))]%></strong></td>
      <td>Status: <strong><%=(String)vCRStudInfo.elementAt(11)%></strong></td>
    </tr>
<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Foreign Student</td>
      <td colspan="2"><font color="#9900FF"><strong> 
        <%
	  if( ((String)vCRStudInfo.elementAt(16)).compareTo("1") ==0){%>
        YES 
        <%}else{%>
        NO 
        <%}%>
        </strong></font></td>
    </tr>
-->	
    <tr> 
      <td height="19" colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td align="right" valign="top" width="75%"> <table bgcolor="#FFFFFF" width="98%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td height="25" colspan="3" bgcolor="#97ABC1" class="thinborderALL"><div align="center">::: 
                <strong>Possible Optional Charges :::</strong></div></td>
          </tr>
          <tr> 
            <td height="25" bgcolor="#FFFFDF" class="thinborderBOTTOMLEFT"><div align="center"><font size="1">SELECT</font> 
                <input type="checkbox" name="selAll" onClick="checkAll();" checked>
              </div></td>
            <td bgcolor="#FFFFDF" class="thinborderBOTTOMLEFT"><div align="center">FEE 
                NAME</div></td>
            <td bgcolor="#FFFFDF" class="thinborderBOTTOMLEFTRIGHT"><div align="center">AMOUNT</div></td>
          </tr>
          <%
		int j = 0;
		if(vOptionalFeePayable != null && vOptionalFeePayable.size() > 0) {//scroll down... to get else.
			for(int i = 0; i < vOptionalFeePayable.size(); i +=3,++j){%>
          <tr> 
            <td width="3%" height="25" class="thinborderBOTTOMLEFT"><div align="center"> 
                <input type="checkbox" name="fee_<%=j%>" value="<%=(String)vOptionalFeePayable.elementAt(i)%>" checked>
              </div></td>
            <td width="56%" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vOptionalFeePayable.elementAt(i + 1)%></td>
            <td width="13%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=(String)vOptionalFeePayable.elementAt(i + 2)%></td>
          </tr>
          <%}//end of for loop.%>
          <tr> 
            <td height="25" colspan="3" align="center" class="thinborderBOTTOMLEFTRIGHT"> 
              <a href="javascript:PageAction(1,'');"><img src="../../../images/save.gif" border="0"></a>Click 
              to add in assessment</td>
          </tr>
          <tr> 
            <td height="25" colspan="3" class="thinborderBOTTOMLEFTRIGHT">&nbsp; </td>
          </tr>
          <%}else{%>
          <tr> 
            <td height="25" colspan="3" class="thinborderBOTTOMLEFTRIGHT">&nbsp; 
              No Optional Fee to charge. </td>
          </tr>
          <%}%>
          <input type="hidden" name="max_disp" value="<%=j%>">
        </table></td>
      <td align="center" valign="top"> <table bgcolor="#FFFFFF" width="94%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="22%" height="25" bgcolor="#FFFFDF" class="thinborderALL"><div align="center">:::<strong> 
                Oth. Setting :::</strong></div></td>
          </tr>
          <tr> 
            <td height="25" class="thinborderBOTTOMLEFTRIGHT">Pmt Mode: 
              <%
			  strTemp = WI.fillTextValue("pmt_mode");
			  if(strTemp.compareTo("0") ==0)
			  	strTemp = " checked";
			  else	
			  	strTemp = "";
			 %>
			 <input type="radio" name="pmt_mode" value="0"<%=strTemp%>>Full 
			 <%if(strTemp.length() == 0) 
			 	strTemp = " checked";
			   else
			   	strTemp = "";
			 %>
              <input type="radio" name="pmt_mode" value="1"<%=strTemp%>>Installment </td>
          </tr>
          <tr> 
            <td height="25" class="thinborderBOTTOMLEFTRIGHT">Amt (optional): 
              <input name="amount" type="text" size="8" maxlength="8" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'"  
	  onKeyUP="AllowOnlyFloat('form_','amount');"></td>
          </tr>
          <tr> 
            <td height="25" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><a href="javascript:PageAction(6,'');"><img src="../../../images/save.gif" border="0"></a>Save 
                oth. setting&nbsp;</div></td>
          </tr>
          <tr>
            <td height="25" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
          </tr>
        </table></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td align="right" valign="top" width="75%"> 
		<table bgcolor="#FFFFFF" width="98%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td height="25" colspan="3" bgcolor="#3366FF" class="thinborderALL"><div align="center"><font color="#FFFFFF">::: 
                <strong>Optional charges (Payable) ::: 
                <%if(vRetResult != null && vRetResult.size() > 0) {%>
                <%=(String)vRetResult.remove(0)%> 
                <%}%>
                </strong></font></div></td>
          </tr>
          <tr> 
            <td height="25" bgcolor="#FFFFDF" class="thinborderBOTTOMLEFT"><div align="center">FEE 
                NAME</div></td>
            <td bgcolor="#FFFFDF" class="thinborderBOTTOMLEFT"><div align="center">AMOUNT</div></td>
            <td bgcolor="#FFFFDF" class="thinborderBOTTOMLEFTRIGHT"><div align="center">REMOVE</div></td>
          </tr>
          <%
		if(vRetResult != null && vRetResult.size() > 0) //scroll down... to get else.
			for(int i = 0; i < vRetResult.size(); i +=4){%>
          <tr> 
            <td width="47%" height="25" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
            <td width="14%" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
            <td width="11%" class="thinborderBOTTOMLEFTRIGHT"><a href="javascript:PageAction(0,'<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
          </tr>
          <%}//end of for loop.
		else{%>
          <tr> 
            <td height="25" colspan="3" class="thinborderBOTTOMLEFTRIGHT">&nbsp; 
              No Optional Fee charged. </td>
          </tr>
          <%}%>
        </table>
  	  </td>	
      <td align="center" valign="top"> 
		<table bgcolor="#FFFFFF" width="94%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td height="25" bgcolor="#3366FF" class="thinborderALL"><div align="center"><font color="#FFFFFF"><strong>::: 
                Oth. Setting Applied :::</strong></font></div></td>
          </tr>
          <tr> 
            <td height="25" class="thinborderBOTTOMLEFTRIGHT">&nbsp;Payment Mode: 
			<%if(vOthSetting != null && vOthSetting.size() > 0) {%>
			<%=astrConvertPmtMode[Integer.parseInt((String)vOthSetting.elementAt(1))]%>
			<%}else{%>Not Defined<%}%>
            </td>
          </tr>
          <tr> 
            <td height="25" class="thinborderBOTTOMLEFTRIGHT">&nbsp;Amount Payable: 
			<%if(vOthSetting != null && vOthSetting.size() > 0 && vOthSetting.elementAt(3) != null) {%>
			<%=CommonUtil.formatFloat((String)vOthSetting.elementAt(3),true)%>
			<%}else{%>Not Defined<%}%>
            </td>
          </tr>
          <tr>
            <td height="25" class="thinborderBOTTOMLEFTRIGHT" align="center">&nbsp;
			<%if(vOthSetting != null && vOthSetting.size() > 0) {%>
			<a href="javascript:PageAction(5,'<%=(String)vOthSetting.elementAt(0)%>');"><img src="../../../images/delete.gif" border="0"></a>
			<font size="1">Remove information.</font>
			<%}%></td>
          </tr>
        </table>
	  </td>	
	</tr>
  </table>
  <%}//show only if vCRStudInfo is not null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
