<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script language="JavaScript">

function ReloadPage()
{
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	Vector vRetResult = null;
	Vector vExamName  = null;
	Vector vEditInfo  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	String strPrepareToEdit = null;
	boolean bolErrorInEdit = false;
	int iMaxDisp = 0;
			
	int iTemp = 0;
//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
//end of authenticaion code.
	String strSchCode = dbOP.getSchoolIndex();
	String[] astrSchYrInfo = dbOP.getCurSchYr();
	if (strSchCode == null)
		strSchCode = "";


	ApplicationMgmt appMgmt = new ApplicationMgmt();

	// iAction == 100 --> bypass Authentication for viewing purpose only
	vRetResult = appMgmt.operateOnExamSched(dbOP, request, 100);
	
	if (vRetResult == null){
		strErrMsg = appMgmt.getErrMsg();
//		System.out.println(strErrMsg);
	}
	
	
//	System.out.println("vRetResult : " + vRetResult);
	
%>
<form name="form_" action="./exam_sched.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" bgcolor="#47768F"><div align="center"><strong><font color="#FFFFFF">:::: 
      ENTRANCE EXAMINATION/INTERVIEW PAGE::::</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%> </strong></font></td>
    </tr>
    <tr> 
      <td width="14" height="25">&nbsp;</td>
      <td width="135">School Year /Term</td>
      <td width="600" colspan="2"> 
<%
	strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length() == 0) 
		strTemp = astrSchYrInfo[0];
	
%>
	
	<input name="sy_from" type="text" size="4" maxlength="4"  
	value="<%=strTemp%>" class="textbox" 
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
	strTemp = WI.fillTextValue("sy_to");
	if (strTemp.length() == 0) 
		strTemp = astrSchYrInfo[1];
	
%>
	<input name="sy_to" type="text" size="4" maxlength="4" 
	  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        / 
        <select name="semester">
        <option value="1" >1st Sem</option>
		
          <% strTemp = WI.fillTextValue("semester");
		 if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  
		   if (!strSchCode.startsWith("CPU")) {
			  if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  
		  if(strTemp.equals("0")){%>
          <option value="0" selected=>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%} %>
        </select> <a href="javascript:ReloadPage();"><img src="../../../../images/refresh.gif" border="0"></a> 
        <font size="1">display the exam schedules for this SY. </font></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"> <hr size="1"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="6" bgcolor="#BECED3" class="thinborder"><div align="center"><strong>LIST 
      OF EXAMINATION/INTERVIEW SCHEDULES FOR AY : <%=WI.fillTextValue("sy_from") + " - "+WI.fillTextValue("sy_to")+" , "+
		  dbOP.getHETerm(Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"-1"))).toUpperCase()%></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="20" class="thinborder"><div align="center"><strong><font size="1">SCHEDULE 
          CODE</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">DURATION 
          (MIN)</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><b><font size="1">DATE</font></b></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">START 
          TIME</font></strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><b>VENUE</b></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><b>CONTACT 
          INFORMATION<br>
      </b><font color="#0000FF">(tel no.) </font></font></div></td>
    </tr>
    <%
	String [] astrConvType={"Written","Interview"};
	String [] astrConvTime={" AM"," PM"};
	
	String strCurrExamType = "";
	
	
for(int i = 0 ; i< vRetResult.size(); ++i, ++iMaxDisp){

	if (!strCurrExamType.equals(astrConvType[Integer.parseInt((String)vRetResult.elementAt(i + 18))] +
	(String)vRetResult.elementAt(i+19)))
	{
		strCurrExamType = astrConvType[Integer.parseInt((String)vRetResult.elementAt(i + 18))] +
	(String)vRetResult.elementAt(i+19);
%>
    <tr>
      <td height="25" colspan="6" bgcolor="#FFE8EE" class="thinborder"><strong>&nbsp;<%=astrConvType[Integer.parseInt((String)vRetResult.elementAt(i + 18))]%> ::: <%=(String)vRetResult.elementAt(i+19)%></strong></td>
    </tr>
<%}%>
    <tr> 
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+5))%></div></td>
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+6))%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+7)%></div></td>
      <td class="thinborder"><div align="center"><%=CommonUtil.formatMinute((String)vRetResult.elementAt(i+8))+':'+
	  CommonUtil.formatMinute((String)vRetResult.elementAt(i+9))+astrConvTime[Integer.parseInt((String)vRetResult.elementAt(i + 10))]%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+12)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+13)%> <br>
          <font color="#0000FF"><%=WI.getStrValue((String)vRetResult.elementAt(i+14),"(", ")","")%></font></div></td>
    </tr>
    <%
	i = i+19;
}%>
  </table>
  
 <%}//if vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<% dbOP.cleanUP();
%>