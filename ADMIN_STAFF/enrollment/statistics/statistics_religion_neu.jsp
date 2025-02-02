<%@ page language="java" import="utility.*,enrollment.VMAEnrollmentReports,java.util.Vector" %>
<%	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS","statistics_enrollees_neu.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	//authenticate this user.
%>
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
function Search(){
	document.form_.page_action.value = "1";
	document.form_.printPg.value="";
	document.form_.submit();
}
function PrintPg(){
	document.form_.printPg.value = "1";
	document.form_.submit();								 
}
</script>
<body bgcolor="#D2AE72">
<%
	if(request.getParameter("printPg") != null && request.getParameter("printPg").compareTo("1") ==0){%>
		
		<jsp:forward page="./statistics_religion_print.jsp" />
	 
	<%}
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Enrollment","STATISTICS",request.getRemoteAddr(),
															"statistics_enrollees_neu.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
	Vector vRetResult = new Vector();	
	Vector vRetTotal = new Vector();
	VMAEnrollmentReports ER = new VMAEnrollmentReports();
	
	if(WI.fillTextValue("page_action").equals("1")){
	   vRetResult = ER.getStudReligionStatistics(dbOP, request, Integer.parseInt(WI.fillTextValue("option")));
	   if(vRetResult == null)
			strErrMsg = ER.getErrMsg();		
	   else
	       vRetTotal = (Vector)vRetResult.remove(0);
	}	
%>
<form name="form_" action="./statistics_religion_neu.jsp" method="post">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><strong>RELIGION STATISTICS</strong></div></td>
    </tr>
	<tr>      
      <td height="25">&nbsp; &nbsp; &nbsp; <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td height="25" width="3%"></td>
      <td width="9%">SY-TERM: </td>
	  <td width="88%">
<%		strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>    <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%		strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>    <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      <select name="semester">
          <option value="1">1st Sem</option>
<%	      strTemp =WI.fillTextValue("semester");
		  if(strTemp.length() ==0) 
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
			if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Date as of:</td>
		<td colspan="2">
		<%strTemp = WI.fillTextValue("date");%>
		<input name="date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Option:</td>
		<td colspan="2"> 
		<select name="option">
          <option value="1">College</option>
<%	      strTemp =WI.fillTextValue("option");
		    if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Basic Education</option>
          <%}else{%>
          <option value="0">Basic Education</option>
          <%}%>
        </select>
		</td>
	</tr>	
    <tr> 
      <td height="19" colspan="4">&nbsp;</td>
    </tr>  
	<tr>
		<td colspan="2">&nbsp;</td>
		<td colspan="2"><a href="javascript:Search();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
	</tr> 
	<tr>
		<td height="20" colspan="4">&nbsp;</td>
	</tr>	
  </table>  
<%if(vRetResult != null && vRetResult.size() > 0){%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
   <tr>
   		<td><hr size="+1"/></td>
   </tr>
    <tr>
      <td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print</font></td>
    </tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
  </table>
   <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">   
     <%if(WI.fillTextValue("option").equals("1")){
	       strTemp = "College Courses";
	   }else{
	   	  strTemp ="GRADE LEVEL";	   
	   }	 
	 %>
   
   
    <tr>
      <td height="26" rowspan="2" class="thinborder" align="center"><strong><%=strTemp%></strong></td>
      <td colspan="3" height="15" class="thinborder" align="center"><strong>NEW</strong></td>
	  <td colspan="3" class="thinborder" align="center"><strong>OLD</strong></td>
	  <td width="8%" rowspan="2" class="thinborder" align="center"><strong>TOTAL INC</strong></td>
	  <td width="8%" rowspan="2" class="thinborder" align="center"><strong>TOTAL NON INC</strong></td>
	  <td width="8%" rowspan="2" class="thinborder" align="center"><strong>GRAND TOTAL</strong></td>
    </tr>
	<tr>
		<td width="9%" height="15" align="center" class="thinborder"><strong>INC</strong></td>
		<td width="9%" align="center" class="thinborder"><strong>Non-INC</strong></td>
		<td width="8%" align="center" class="thinborder"><strong>TOTAL</strong></td>
		<td width="9%" align="center" class="thinborder"><strong>INC</strong></td>
		<td width="8%" align="center" class="thinborder"><strong>Non-INC</strong></td>
		<td width="7%" align="center" class="thinborder"><strong>TOTAL</strong></td>
	</tr>
	<%
	int iSubINCTot = 0;
	int iSubNonINCTot = 0;
	
	int iOldSubINCTot = 0;
	int iOldSubNonINCTot = 0;
	String strCurrCCName = null;
	String strPrevCCName = "";
	for(int i = 0; i < vRetResult.size(); i += 10){
	
		strCurrCCName = (String)vRetResult.elementAt(i+1);
	  if(!strPrevCCName.equals(strCurrCCName)&& i >= 0){ //
	  	strPrevCCName = strCurrCCName;
		
		if(i > 0){
	%>		
		
	  <tr style="font-weight:bold;">
	  	<td align="right" height="25" class="thinborder" style="padding-right:40px;">SUB-TOTAL</td>
	  	<td height="25" class="thinborder" align="center"><%=iSubINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iSubINCTot+iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot+iOldSubINCTot%></td>
		<td class="thinborder" align="center"><%=iOldSubINCTot+iSubINCTot%></td>
		<td class="thinborder" align="center"><%=iOldSubNonINCTot+iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot+iOldSubINCTot+iSubINCTot+iSubNonINCTot%></td>
	  </tr>	
	  <%
	  iSubINCTot = 0;
	  iSubNonINCTot = 0;
	  iOldSubINCTot = 0;
	  iOldSubNonINCTot = 0;
	  }%>
		
		<tr>
		  <td height="20" colspan="10" class="thinborder"><strong><%=WI.getStrValue(strCurrCCName).toUpperCase()%></strong></td>
		</tr>
	<%}%>
	
	  <tr>
	  	<td height="25" style="padding-left:40px;" class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
	  	<td style="text-align:center" height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"0")%></td>
		<td style="text-align:center" height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"0")%></td>
		<td style="text-align:center" height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"0")%></td>
		<td style="text-align:center" height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"0")%></td>
		<td style="text-align:center" height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"0")%></td>
		<td style="text-align:center" height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+8),"0")%></td>
		<%
		strTemp = Integer.toString(Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+3),"0"))+Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+6),"0")));
		%>
		<td style="text-align:center" class="thinborder"><%=strTemp%></td>
		<%
		strTemp = Integer.toString(Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+4),"0"))+Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+7),"0")));
		%>
		<td style="text-align:center" class="thinborder"><%=strTemp%></td>
		<td style="text-align:center" height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+9),"0")%></td>
	  </tr>	
    <%
	
	iSubINCTot += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+3),"0"));
	iSubNonINCTot  += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+4),"0"));
	
	iOldSubINCTot += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+6),"0"));
	iOldSubNonINCTot  += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+7),"0"));
	}// end of vRetResult loop%>
	<tr style="font-weight:bold;">
	  	<td align="right" height="25" class="thinborder" style="padding-right:40px;">SUB-TOTAL</td>
	  	<td height="25" class="thinborder" align="center"><%=iSubINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iSubINCTot+iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot+iOldSubINCTot%></td>
		<td class="thinborder" align="center"><%=iOldSubINCTot+iSubINCTot%></td>
		<td class="thinborder" align="center"><%=iOldSubNonINCTot+iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot+iOldSubINCTot+iSubINCTot+iSubNonINCTot%></td>
	</tr>

<%
int iTotNONINC = 0;
int iTotINC = 0;
%>
	<tr style="font-weight:bold;">
		<td class="thinborder" align="right" style="padding-right:40px;" height="25"><font color="#FF0000">GRAND TOTAL</font></td>
		<%
		strTemp = (String)vRetTotal.remove(0);
		iTotINC = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		%>
		<td class="thinborder" align="center"><font color="#FF0000"><%=strTemp%></font></td>
		<%
		strTemp = (String)vRetTotal.remove(0);
		iTotNONINC = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		%>
		<td class="thinborder" align="center"><font color="#FF0000"><%=strTemp%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=vRetTotal.remove(0)%></font></td>
		<%
		strTemp = (String)vRetTotal.remove(0);
		iTotINC += Integer.parseInt(WI.getStrValue(strTemp,"0"));
		%>
		<td class="thinborder" align="center"><font color="#FF0000"><%=strTemp%></font></td>
		<%
		strTemp = (String)vRetTotal.remove(0);
		iTotNONINC += Integer.parseInt(WI.getStrValue(strTemp,"0"));
		%>
		<td class="thinborder" align="center"><font color="#FF0000"><%=strTemp%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=vRetTotal.remove(0)%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=iTotINC%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=iTotNONINC%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=vRetTotal.remove(0)%></font></td>
	</tr>
  </table>

<%} // end of vRetResult!=null && vRetResult.size()>0%>
<table width="100%" border="0" cellspacing="0" cellpadding="0"  id="myADTable4">
	<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
	<tr bgcolor="#A49A6A"><td height="25" colspan="3">&nbsp;</td></tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="printPg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
