<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
function RefreshPage() {
	location = "./circulation_type_param.jsp?patron_type_index="+document.form_.patron_type_index.value+
	"&patron_type="+escape(document.form_.patron_type.value);
}
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>

<%@ page language="java" import="utility.*,lms.MgmtCirculation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-CIRCULATION","circulation_type_param.jsp");
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
														"LIB_Administration","CIRCULATION",request.getRemoteAddr(),
														"circulation_type_param.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	MgmtCirculation mgmtBPCONFIG = new MgmtCirculation();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtBPCONFIG.operateOnCirTypeParam(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtBPCONFIG.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Circulation type parameter information successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Circulation type parameter information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Circulation type parameter information successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = mgmtBPCONFIG.operateOnCirTypeParam(dbOP, request,4);	
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtBPCONFIG.operateOnCirTypeParam(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtBPCONFIG.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC">
<form action="./circulation_type_param.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION MANAGEMENT - CIRCULATION TYPE PARAMETER SETUP PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="38" colspan="6"><a href="borrowing_param.jsp"><img src="../../images/go_back.gif" width="54" height="29" border="0"></a>&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="5"><strong>PATRON TYPE : <%=WI.fillTextValue("patron_type").toUpperCase()%></strong></td>
    </tr>
    <tr> 
      <td height="18" colspan="6"><hr size="1" color="#00CCFF"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Circulation Type</td>
      <td colspan="3">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("CIR_TYPE_INDEX");
%>	  <select name="CIR_TYPE_INDEX">
<%=dbOP.loadCombo("CTYPE_INDEX","description",
	" from LMS_CLOG_CTYPE where is_valid = 1 and IS_DEL=0 and CHECK_OUT=1 order by description asc", strTemp, false)%>
      </select>
	  </td>
    </tr>
    <tr> 
      <td height="19" colspan="6"><hr size="1" color="#00CCFF"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="1%">&nbsp;</td>
      <td width="16%">Loan Period</td>
      <td width="22%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("LOAN_PERIOD");
%>	  <input type="text" name="LOAN_PERIOD" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        <select name="LOAN_PERIOD_UNIT">
          <option value="0">day(s)</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("LOAN_PERIOD_UNIT");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>hour(s)</option>
<%}else{%>
          <option value="1">hour(s)</option>
<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>fixed</option>
<%}else{%>
          <option value="2">fixed</option>
<%}%>        </select></td>
      <td width="16%">Grace Period</td>
      <td width="42%"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("GRACE_PERIOD");
%>	  <input type="text" name="GRACE_PERIOD" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        <select name="GRACE_PERIOD_UNIT">
          <option value="0">day(s)</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("GRACE_PERIOD_UNIT");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>hour(s)</option>
<%}else{%>
          <option value="1">hour(s)</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Max. Renewal</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("MAX_RENEW");
%>        <input type="text" name="MAX_RENEW" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	   time(s)</td>
      <td>Fine Increment</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("FINE_INCR");
%>        <input type="text" name="FINE_INCR" size="8" maxlength="8" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress="if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Max. Loan for this Circ. Type</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("MAX_LOAN");
%>        <input type="text" name="MAX_LOAN" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        time(s)</td>
      <td>Fine Max. Implemented</td>
      <td> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("MAX_FINE");
%>	  <input type="text" name="MAX_FINE" size="8" maxlength="8" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.getStrValue(strTemp)%>"
	  onKeypress="if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
	  <select name="MAX_FINE_UNIT">
          <option value="0">Amount</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("MAX_FINE_UNIT");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Price of Item Loaned</option>
<%}else{%>
          <option value="1">Price of Item Loaned</option>
<%}%>
        </select> </td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="0%" height="25">&nbsp;</td>
      <td colspan="2" valign="top"> <div align="left"></div></td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="18%" height="40" valign="top"><div align="center"></div></td>
      <td valign="top"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="javascript:RefreshPage();"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries</font></td>
    </tr>
<%}%>	
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><font color="#FF0000"><strong>LIST 
          OF CIRCULATION TYPE SETUP PARAMETERS FOR PATRON TYPE : <%=WI.fillTextValue("patron_type").toUpperCase()%></strong></font></div></td>
    </tr>
    <tr> 
      <td width="20%" height="25" class="thinborder"><div align="center"><font size="1"><strong>CIRCULATION 
          TYPE</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>LOAN PERIOD</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>GRACE PERIOD</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>MAX. RENEWAL</strong></font></div></td>
      <td width="10%" class="thinborder"><font size="1"><strong>MAX. LOAN FOR THIS CIRC. TYPE</strong></font></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>FINE INCREMENT</strong></font></div></td>
      
	  <%if(!strSchoolCode.startsWith("CIT")){%>
	  <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>MAX. FINE OR 
          PENALTY</strong></font></div></td>
		<%}%>
		
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
<%
String[] astrConvertLoanUnit = {" Day(s)"," Hour(s)","FIXED"};
String[] astrConvertFineUnit = {" Per day"," Per hour"," Per day"};

for(int i = 0; i < vRetResult.size(); i += 12){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 3))%>
	  <%=astrConvertLoanUnit[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%></td>
      <td class="thinborder">&nbsp;
	  <%if(vRetResult.elementAt(i + 5) != null) {%>
	  	<%=(String)vRetResult.elementAt(i + 5)%>
	  
	  	<%if(!strSchoolCode.startsWith("CIT")){%>
	  		<%=astrConvertLoanUnit[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%>
	  	<%}else{%>
	  		<%=astrConvertFineUnit[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%>	  
	  	<%}
	  }%>
	  </td>
      <td class="thinborder">&nbsp;
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),""," time(s)","")%></td>
      <td class="thinborder">&nbsp;
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 8),""," time(s)","")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 9))%>
	  <%=astrConvertFineUnit[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%></td>
      
	  <%if(!strSchoolCode.startsWith("CIT")){%>
	  <td class="thinborder">&nbsp;
	  <%if(vRetResult.elementAt(i + 10) == null) {%>
	  	Price of Item Loanded<%}else{%>
		<%=(String)vRetResult.elementAt(i + 10)%> Amount
		<%}%></td>
		<%}%>
		
      <td class="thinborder"><div align="center"> 
          <%
if(iAccessLevel > 1){%>
          <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a> 
          <%}if(iAccessLevel == 2){%>
          <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a> 
          <%}%>
        </div></td>
    </tr>
<%}//end of for loop%>
	
  </table>
<%}//end of vRetResult is not null
%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">


<input type="hidden" name="patron_type" value="<%=WI.fillTextValue("patron_type")%>">
<input type="hidden" name="patron_type_index" value="<%=WI.fillTextValue("patron_type_index")%>">
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>