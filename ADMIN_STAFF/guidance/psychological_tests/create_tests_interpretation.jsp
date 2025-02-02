<%@ page language="java" import="utility.*, osaGuidance.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolAUF = (strSchCode.startsWith("AUF") || strSchCode.startsWith("UB"));


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">


<style type="text/css">

 /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:7;
	top:8;
    width:250px;

    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }

</style>



<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
	document.form_.print_pg.value = "";
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}
function ChangeTest()
{
	document.form_.test_name.value = document.form_.test_index[document.form_.test_index.selectedIndex].text;
	this.SubmitOnce("form_");
}

function HideLayer(strDiv) {			
	document.getElementById(strDiv).style.visibility = 'hidden';
}

function UpdateTestProfile(){
	var pgLoc = "./percentile_score_map.jsp?is_forwarded=1";
	var win=window.open(pgLoc,"UpdateTestProfile",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
}

</script>
</head>
<%
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./create_tests_interpretation_print.jsp" />
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
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","create_tests_interpretation.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = null;

	GDPsychologicalTest PsychTest = new GDPsychologicalTest();
	
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
	if(strTemp.length() > 0) {
		if(PsychTest.operateOnPsychIntAssign(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else
			strErrMsg = PsychTest.getErrMsg();
	}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = PsychTest.operateOnPsychIntAssign(dbOP, request, 3);	
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = PsychTest.getErrMsg();
	}

	vRetResult = PsychTest.operateOnPsychIntAssign(dbOP, request, 4);
	if (vRetResult == null && strErrMsg ==  null)
		strErrMsg = PsychTest.getErrMsg();
		
	Vector vPercentile = PsychTest.operateOnPercentileMapping(dbOP, request, 4);
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./create_tests_interpretation.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING - SET PSYCHOLOGICAL INTERPRETATION PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td width="15%"><font size="1">Test Name</font></td>
      <td colspan="2" valign="middle"> 
      <%
      if (vEditInfo!=null && vEditInfo.size()>0)
      strTemp = (String)vEditInfo.elementAt(1);
      else
      strTemp = WI.fillTextValue("test_index");%>
		<select name="test_index" onChange="ChangeTest();">
          <option value="">Select test</option>
		<%=dbOP.loadCombo("test_name_index","test_name"," from gd_psytest_name where is_valid = 1 order by test_name", strTemp, false)%>
    </select></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><font size="1">Test Factor</font></td>
      <td colspan="2" valign="middle">
      <%
      if (vEditInfo!=null && vEditInfo.size()>0)
      strTemp = WI.getStrValue((String)vEditInfo.elementAt(2),"");
      else
      strTemp = WI.fillTextValue("factor_index");%>
		<select name="factor_index">
        <!--<option value="">ALL Factors</option>-->
		<%if (WI.fillTextValue("test_index").length()>0){%>
		<%=dbOP.loadCombo("test_factor_index","factor_name+' ('+factor_code+')' as fac_name"," from gd_psytest_factor where is_valid = 1 and test_name_index = "+WI.fillTextValue("test_index")+" order by factor_order", strTemp, false)%>
		<%}%>
    </select>      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><font size="1">Interpretation Name</font></td>
      <td colspan="2" valign="middle">
	    <%
	    if (vEditInfo!=null && vEditInfo.size()>0)
	    strTemp = (String)vEditInfo.elementAt(5);
    	else
	    strTemp = WI.fillTextValue("int_name");%>
    	<input name="int_name" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" maxlength="12" value="<%=strTemp%>">      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td><font size="1">Classification</font></td>
      <td colspan="2" valign="middle">
	    <%
	     if (vEditInfo!=null && vEditInfo.size()>0)
	     strTemp = (String)vEditInfo.elementAt(6);
    	 else
	    strTemp = WI.fillTextValue("cls");%>
    	<input name="cls" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" maxlength="16" value="<%=strTemp%>">      </td>
    </tr>
      <tr> 
      <td height="30">&nbsp;</td>
      <td><font size="1">Range</font></td>
      <td height="30" colspan="2" valign="middle">
      <%
      if (vEditInfo!=null && vEditInfo.size()>0)
      strTemp = (String)vEditInfo.elementAt(7);
      else
      strTemp = WI.fillTextValue("range_fr");%> 
       <input name="range_fr" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	   onKeyUp= 'AllowOnlyInteger("form_","range_fr")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","range_fr");style.backgroundColor="white"'>&nbsp;to&nbsp;
		<%
		if (vEditInfo!=null && vEditInfo.size()>0)
    	strTemp = WI.getStrValue((String)vEditInfo.elementAt(8),"");
	    else
		strTemp = WI.fillTextValue("range_to");%> 
       <input name="range_to" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	   onKeyUp= 'AllowOnlyInteger("form_","range_to")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","range_to");style.backgroundColor="white"'>
		&nbsp;<%
		 if (vEditInfo!=null && vEditInfo.size()>0)
	     strTemp = (String)vEditInfo.elementAt(9);
    	 else
		strTemp = WI.getStrValue(WI.fillTextValue("isper"),"0");
		if (strTemp.compareTo("1")==0){%>
	   	<input type="checkbox" name="isper" value="1" checked>
	   	<%}else{%>
	   	<input type="checkbox" name="isper" value="1">
	   	<%}%><font size="1">check if percentile      </td>
    </tr>
<%
if(bolAUF){
%>
      <tr>
          <td height="30">&nbsp;</td>
          <td><font size="1">Gender</font></td>
          <td height="30" colspan="2" valign="middle">
		  <%		
		  	
			strTemp = WI.fillTextValue("gender");	
			if (vEditInfo!=null && vEditInfo.size()>0)
		        strTemp = WI.getStrValue((String)vEditInfo.elementAt(10),"2");
		  	
			if(strTemp.equals("2") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		  %><input type="radio" name="gender" value="2" <%=strErrMsg%> >Not Applicable		  
		  <%			
			if(strTemp.equals("0"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		  %><input type="radio" name="gender" value="0" <%=strErrMsg%> >Male
		  <%			
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		  %><input type="radio" name="gender" value="1" <%=strErrMsg%> >Female
		  </td>
      </tr>
<%}%>  
    <tr> 
      <td height="47">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="49%" height="47" valign="bottom">
	    <%if (iAccessLevel > 1){%>
	    <font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font><%} else {%>&nbsp;<%}%>      </td>
      <td width="33%" valign="bottom">
	  	<a href="javascript:UpdateTestProfile();"><img src="../../../images/update.gif" border="0"></a>
		<font size="1">create/update test profile</font>	  </td>
    </tr>
    <%if (vRetResult != null && vRetResult.size()>0) {%>
    <tr> 
      <td height="25" colspan="4" align="right"><font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a>click to print list</font></td>
    </tr>
	<%}%>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#C78D8D"> 
      <td  height="25" colspan="7" align="center" class="thinborder"><font color="#FFFFFF"><strong>PSYCHOLOGICAL 
        TESTS INTERPRETATION FOR <%=WI.fillTextValue("test_name")%> </strong></font></td>
    </tr>
    <tr> 
      <td width="20%"  height="28" align="center" class="thinborder"><font size="1"><strong>INTERPRETATION 
        NAME </strong></font></div></td>
      <td width="20%" align="center" class="thinborder"><strong><font size="1">FACTOR</font></strong></td>
      <td width="17%" align="center" class="thinborder"><strong><font size="1">RANGE</font></strong></td>
      <td width="17%" align="center" class="thinborder"><strong><font size="1">CLASSIFICATION</font></strong></td>
	<%if(bolAUF){%>
		<td width="17%" align="center" class="thinborder"><strong><font size="1">GENDER</font></strong></td>
	<%}%>
      <td width="26%" class="thinborder">&nbsp;</td>
    </tr>
    <%for(i=0; i<vRetResult.size(); i+=11){%>
    <tr> 
      <td  height="26" class="thinborder"><font size="1">&nbsp; 
        <%if (i>0 && vRetResult.elementAt(i+5).equals(vRetResult.elementAt(i-5))){%>
        &nbsp;
        <%} else {%>
        <%=(String)vRetResult.elementAt(i+5)%>
        <%}%>
        </font></td>
      <td class="thinborder"><font size="1">&nbsp; 
        <%if (vRetResult.elementAt(i+2)!=null){%>
        <%=(String)vRetResult.elementAt(i+3)%>(<%=(String)vRetResult.elementAt(i+4)%>) 
        <%} else {%>
        ALL FACTORS
        <%}%>
        </font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+7)%><%=WI.getStrValue((String)vRetResult.elementAt(i+8)," - ",""," and up")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></font></td>
	  <%
	  String[] astrGender = {"Male", "Female", "Not Applicable"};
	  strTemp = astrGender[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+10),"2"))];
	
		if(bolAUF){%>
	  <td class="thinborder"><font size="1"><%=strTemp%></font></td><%}%>
      <td class="thinborder"><%
      if(iAccessLevel ==2 || iAccessLevel == 3){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        &nbsp;
        <%} if (iAccessLevel == 2) {%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        &nbsp;
        <%}%> </td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" align="center"><font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a>click to print list</font></td>
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
  <input name="test_name" type="hidden" value="<%=WI.fillTextValue("test_name")%>">
  <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="print_pg">

<%if(vPercentile != null && vPercentile.size() > 0){%>  
<div id="processing" class="processing">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#9999CC">
	<!--<tr>
		<td height="14" valign="top" align="right"><a href="javascript:HideLayer('processing')">Close Window X</a></td>
	</tr>-->
	<tr>
		<td valign="top">
			<table cellpadding="0" cellspacing="0" border="0" Width="100%" Height="100%" align="Center">
				<tr><td align="center" ><font size="1">RAW SCORE</font></td>
					<td align="center"><font size="1">PERCENTILE</font></td></tr>
					<%
					for(i = 0; i < vPercentile.size(); i+=3){
					%>
					<tr>
						<td align="center"><font size="1"><%=(String)vPercentile.elementAt(i+1)%></font></td>
						<td align="center"><font size="1"><%=CommonUtil.formatFloat(Double.parseDouble((String)vPercentile.elementAt(i+2)),false)%></font></td>
					</tr>
					<%}%>
			</table>
		</td>
	</tr>
	
	
</table>
</div> 
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>