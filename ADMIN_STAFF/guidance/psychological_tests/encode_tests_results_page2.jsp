<%@ page language="java" import="utility.*, osaGuidance.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.stud_id.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	if (strInfoIndex != "")
		document.form_.stud_id.value = strInfoIndex;
	document.form_.print_pg.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CheckAll()
{
	var iMaxDisp = document.form_.msgCtr.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp)-1;++i)
			eval('document.form_.fac_index'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp)-1;++i)
			eval('document.form_.fac_index'+i+'.checked=false');
		
}
</script>
</head>
<%
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./encode_tests_results_page2_print.jsp" />
	<%}

//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	

	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","encode_tests_results_page2.jsp");
	
	Vector vRetResult = null;
	Vector vSchedData = null;
	Vector vBasicInfo = null;
	Vector vEditInfo = null;
	Vector vFactors = null;
	Vector vTemp = null;
	int i = 0;
	int iFactors = 1;
	int iTableFac = 0;
	String strErrMsg = null;
	String strTemp = null;
	int iTemp = 0;
	int iSearchResult = 0;
	String strPrepareToEdit = null;
	String [] astrConvTime={" AM"," PM"};


	GDPsychologicalTest PsychTest = new GDPsychologicalTest();
	vSchedData = PsychTest.operateOnPsyTestSched(dbOP, request, 3);
	if (vRetResult == null)
		strErrMsg = PsychTest.getErrMsg();
		
	

	vFactors = PsychTest.retrieveFactors(dbOP, WI.fillTextValue("sched_idx"));
	if (vFactors==null && strErrMsg==null)
			strErrMsg = PsychTest.getErrMsg();

	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	if(WI.fillTextValue("stud_id").length() > 0) 
		vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if (vBasicInfo != null && vBasicInfo.size()>0)
	{
		strTemp = WI.fillTextValue("page_action");	
		strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
		if(strTemp.length() > 0) {
		if(PsychTest.operateOnTestResultEncoding(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else
			strErrMsg = PsychTest.getErrMsg();
		}
		
		if(strPrepareToEdit.compareTo("1") == 0) {
			vEditInfo = PsychTest.operateOnTestResultEncoding(dbOP, request, 3);
	
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = PsychTest.getErrMsg();
		}
	}
	else if (vBasicInfo == null && strErrMsg==null)
		strErrMsg = OAdm.getErrMsg();
		
	vRetResult = PsychTest.operateOnTestResultEncoding(dbOP, request, 4);
	if (vRetResult == null && strErrMsg==null)
		strErrMsg = PsychTest.getErrMsg();
	else
		iSearchResult = PsychTest.getSearchCount();		
%>
<body bgcolor="#FFFFFF">
<form name="form_" action="encode_tests_results_page2.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING - CREATE PSYCHOLOGICAL TESTS SCHEDULES PAGE 
          ::::</strong></font></div></td>
    </tr>
</table>
<%if (vSchedData!=null && vSchedData.size()>0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">School Year / Term : <strong>
      <%=(String)vSchedData.elementAt(1)+ " - "+(String)vSchedData.elementAt(2)+
			WI.getStrValue((dbOP.getHETerm(Integer.parseInt(WI.getStrValue((String)vSchedData.elementAt(3),"-1"))).toUpperCase()),", ","","")%>
      </strong></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td width="35%">Schedule Code : <strong><%=((String)vSchedData.elementAt(6))%></strong></td>
      <td width="61%" valign="middle">Test Name : <strong><%=((String)vSchedData.elementAt(5))%></strong> 
      </td>
    </tr>
    <tr> 
      <td width="4%" height="30">&nbsp;</td>
      <td colspan="2">Administered by : <strong>
      <%=WI.formatName((String)vSchedData.elementAt(15),(String)vSchedData.elementAt(16),(String)vSchedData.elementAt(17),1)%>
      </strong></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30">Date Test Given : <strong>
      <%=((String)vSchedData.elementAt(8))%></strong></td>
      <td height="30">Time Given : <strong>
      <%=CommonUtil.formatMinute((String)vSchedData.elementAt(9))+':'+
	  CommonUtil.formatMinute((String)vSchedData.elementAt(10))+astrConvTime[Integer.parseInt((String)vSchedData.elementAt(11))]%>
	  </strong></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Duration : <strong><%=((String)vSchedData.elementAt(7))%> minutes</strong></td>
      <td height="30" valign="middle">Venue : <strong>
      <%=((String)vSchedData.elementAt(13))%></strong></td>
    </tr>
    <tr> 
      <td height="19" colspan="3"><hr size="1"> </td>
    </tr>
	</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="40">&nbsp;</td>
      <td width="15%">Student ID : </td>
      <td width="20%"><%
	 if (vEditInfo!=null && vEditInfo.size()>0) 
		 	strTemp = (String)vEditInfo.elementAt(1);
	 	else
			strTemp = WI.fillTextValue("stud_id");%>
     <input name="stud_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="10%" align="left"><a href="javascript:StudSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="51%"><a href='javascript:PrepareToEdit("");'><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    </table>
  <%if (vBasicInfo != null && vBasicInfo.size()>0){
  strTemp =(String)vBasicInfo.elementAt(19);%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font color="#FFFFFF"><strong>:: STUDENT INFORMATION 
        ::</strong></font></td>
    </tr>
   <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student Name :<strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td height="25">Gender : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"Not defined")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Brithdate : <strong><%=WI.getStrValue(strTemp, "Undefined")%></strong></td>
      <td height="25">Age :<strong><%if (strTemp !=null && strTemp.length()>0){%><%=CommonUtil.calculateAGEDatePicker(strTemp)%><%}else{%>Undefined<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Course/Major : <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Year Level : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <% if (vFactors != null && vFactors.size()>0){
  if (vEditInfo!= null && vEditInfo.size()>0)
  	vTemp = (Vector)vEditInfo.elementAt(7);
  %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="4%"><input type="checkbox" name="selAll" value="0" onClick="CheckAll();"></td>
      <td width="48%"><strong><u>FACTOR</u></strong></td>
      <td width="48%"><strong><u>SCORE</u></strong></td>
    </tr>
  	<%
 int x=0;
  	for (i=0; i<vFactors.size(); i+=4, ++iFactors, x+=2){%>
    <tr> 
      <td height="25">
      <%
      strTemp = WI.fillTextValue("fac_index"+iFactors);
      if (strTemp.length()>0){%>
      <input type="checkbox" name="fac_index<%=iFactors%>" value="<%=(String)vFactors.elementAt(i)%>" checked>
      <%} else {%>
      <input type="checkbox" name="fac_index<%=iFactors%>" value="<%=(String)vFactors.elementAt(i)%>"><%}%>
      </td>
      <td align="left"><%=(String)vFactors.elementAt(i+1)%> ( <%=(String)vFactors.elementAt(i+2)%> ) </td>
      <td align="left">
      <%
      if (vTemp!=null&&vTemp.size()>0)
	      strTemp = (String)vTemp.elementAt(x);
      else
    	  strTemp = WI.fillTextValue("score"+iFactors);
    if (strTemp.equals("#"))
	    strTemp = "";%>
      <input name="score<%=iFactors%>" type="text" id="score" size="4" maxlength="4" class="textbox"
        onKeyUp= 'AllowOnlyInteger("form_","score<%=iFactors%>")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","score<%=iFactors%>");style.backgroundColor="white"' value="<%=strTemp%>"></td>

    </tr>
    <%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
      <td width="12%">&nbsp;</td>
      <td width="88%" height="49" valign="middle">
      <%if (iAccessLevel > 1) {%><font size="1">
      <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>Save changes
      <%if (strPrepareToEdit.equals("1") && vEditInfo!= null && vEditInfo.size()>0){%>
      <a href='javascript:PageAction("0","")'><img src="../../../images/delete.gif" border="0"></a>Invaidate scores  
	  <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>Cancel edit
      <%}%></font><%} else {%>&nbsp;<%}%>
      </td>
    </tr>
  </table>
  <%}//vfactors
  }//stud info
  if (vRetResult!=null && vRetResult.size()>0 && vFactors!= null && vFactors.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	 <tr> 
      <td height="25" align="right"><font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a>click to print list</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#C78D8D"> 
      <td  height="25" colspan="<%=((vFactors.size()/4)+4)%>"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF TESTS RESULTS FOR : <%=((String)vSchedData.elementAt(5)).toUpperCase()%> </strong></font></div></td>
    </tr>
    <tr> 
      <td width="15%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>STUDENT ID</strong></font></td>
      <td width="20%" height="28" rowspan="2" align="center" class="thinborder"><font size="1"><strong>STUDENT NAME </strong></font></td>
      <td width="20%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>COURSE<br>/YEAR LEVEL </strong></font></td>
      <td height="19" colspan="<%=vFactors.size()/4%>" align="center" class="thinborder"><font size="1"><strong>SCORE
	  </strong></font></td>
      <td rowspan="2" class="thinborder">&nbsp;</td>
    </tr>
    <tr> 
      <%for (iTableFac=0;iTableFac<vFactors.size();iTableFac+=4){%>
      <td height="20" align="center" class="thinborder"><strong><font size="1"><%=(String)vFactors.elementAt(iTableFac+2)%></font></strong></div></td>
	<%}%>
    </tr>
	<%for (i=0; i<vRetResult.size(); i+=8) {%>
    <tr> 
      <td class="thinborder" height="26"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1">
      <%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"<br>/ ","","")%>
      </font></td>
	<%
	vTemp = (Vector)vRetResult.elementAt(i+7);
	if(vTemp==null || vTemp.size()==0){
	for (iTableFac=0;iTableFac<(vFactors.size()/4);++iTableFac){%>
      <td class="thinborder">&nbsp;</td>
	<%}}else{
	for (iTableFac=0; iTableFac<vTemp.size();iTableFac+=2){%>
	<td align="center" class="thinborder"><font size="1"><%=(String)vTemp.elementAt(iTableFac)%><br><%=(String)vTemp.elementAt(iTableFac+1)%></font></td>
	<%}}%>
      <td class="thinborder">
		<%if (iAccessLevel > 1) {%>
      <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../../../images/edit.gif" border="0"></a>
      <%} else {%>&nbsp;<%}%></td>
    </tr>
    <%}%>
    <tr> 
      <td  height="25" colspan="3" align="left" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL 
          PYSCHOLOGICAL TESTS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="<%=((vFactors.size()/4)+1)%>" align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = 1;
		if(PsychTest.defSearchSize > 0) {
			iPageCount = iSearchResult/PsychTest.defSearchSize;
			if(iSearchResult % PsychTest.defSearchSize > 0) ++iPageCount;
		}
		if(iPageCount > 1){%><select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}// end page printing
			%>
          </select>
          <%} else {%>&nbsp;<%} //if no pages %></td>
    </tr>

  </table>
  <%}%>
  <%} else {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
<input type="hidden" name="sched_idx" value="<%=WI.fillTextValue("sched_idx")%>">
<input type="hidden" name="msgCtr" value ="<%=iFactors%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

