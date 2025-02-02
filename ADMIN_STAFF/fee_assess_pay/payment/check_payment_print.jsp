<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,enrollment.CheckPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Check Payment Management",
								"check_payment_print.jsp");
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
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"check_payment_print.jsp");
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

	Vector vRetResult = null;
	CheckPayment CP = new CheckPayment();
	int iSearch = 0;
	int iDefault = 0;
	int iLoop = 0;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	boolean bolPageBreak = false;
	String[] astrChkStat = {"For Clearing","Cleared","Bounced"};
	String[] astrSchTerm = {"Summer","First Sem","Second Sem"," Third Sem"};
	String strBank = null;
	String strExamSch = null;
	vRetResult = CP.searchList(dbOP,request);
	if(vRetResult == null)
		strErrMsg = CP.getErrMsg();
	else
		iSearch = CP.getSearchCount();
	if(WI.fillTextValue("bank").length() > 0)
		strBank = dbOP.mapOneToOther("FA_BANK_LIST","BANK_INDEX",WI.fillTextValue("bank"),"BANK_CODE"," and IS_DEL = 0");
	if(WI.fillTextValue("exam_sched").length() > 0)
		strExamSch = dbOP.mapOneToOther("FA_PMT_SCHEDULE","PMT_SCH_INDEX",WI.fillTextValue("exam_sched"),"EXAM_NAME"," and IS_DEL = 0");
			
	if(vRetResult != null ){
	for(;iLoop < vRetResult.size();){			
%>
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
    <td height="25" colspan="2"><div align="center"> 
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
        </div></td>
  </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">School Year / Term</font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> / <%=astrSchTerm[Integer.parseInt(WI.fillTextValue("semester"))]%></font></strong></td>
      <%if(!WI.fillTextValue("removeStud").equals("1")){%>
	  	<td><font size="1">Date of Payment</font></td>
      	<td><strong><font size="1"><%=WI.getStrValue(WI.fillTextValue("date_fr"),"-")%> <%=WI.getStrValue(WI.fillTextValue("date_to")," - ","","")%></font></strong></td>
	  <%}%>
	</tr>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">Check No.</font></td>
      <td width="26%"><font size="1"><strong> 
        <%if(WI.fillTextValue("check_no_select").equals("equals")){%>
        <%=WI.getStrValue(WI.fillTextValue("check_no"),"-")%> 
        <%}else if(WI.fillTextValue("check_no_select").equals("contains")){%>
        <%=WI.fillTextValue("check_no_select") +" - "+ WI.getStrValue(WI.fillTextValue("check_no"),"-")%> 
        <%}else{%>
        <%=WI.fillTextValue("check_no_select") +" with - "+ WI.getStrValue(WI.fillTextValue("check_no"),"-")%> 
        <%}%>
        </strong></font></td>
      <td width="20%"><font size="1">Bank</font></td>
      <td width="31%"><strong><font size="1"><%=WI.getStrValue(strBank,"All")%> </font></strong></td>
    </tr>
	<%if(!WI.fillTextValue("removeStud").equals("1")){%>   
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Exam Schedule</font></td>
      <td><strong><font size="1"><%=WI.getStrValue(strExamSch,"All")%></font></strong></td>      
	  <td><font size="1">Check Status</font></td>	  
      <td><strong><font size="1"> 
        <%if(WI.fillTextValue("check_status").length() > 0){%>
        <%=astrChkStat[Integer.parseInt(WI.fillTextValue("check_status"))]%> 
        <%}else{%>
        All 
        <%}%>
        </font></strong></td>	  
	  
    </tr>
	<%}%>
  </table>
  <br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <%if(WI.fillTextValue("removeStud").equals("1")){%>
    <tr> 
      <td  height="25" colspan="9" class="thinborderBOTTOM"><div align="center"><font size="1" ><strong>LIST 
          OF BLOCKED CHECK PAYMENTS</strong></font></div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td  height="25" colspan="9" class="thinborderBOTTOM"><div align="center"><font size="1" ><strong>LIST 
          OF CHECK PAYMENTS</strong></font></div></td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="9" class="thinborderBOTTOM"><strong><font size="1">TOTAL RESULT 
        : <%=iSearch%></font></strong></td>
    </tr>
    <tr> 
      <td width="5%" height="25" class="thinborderBOTTOMRIGHT"><div align="center"><strong><font size="1"> 
          NO.</font></strong></div></td>
      <td width="10%" class="thinborderBOTTOMRIGHT"><div align="center"><font size="1"><strong>STUDENT 
          ID </strong></font></div></td>
      <td width="20%" class="thinborderBOTTOMRIGHT"><div align="center"><strong><font size="1">PAYEE NAME </font></strong></div></td>
      <td width="5%" class="thinborderBOTTOMRIGHT"><div align="center"><font size="1"><strong>BANK</strong></font></div></td>
      <td width="15%" class="thinborderBOTTOMRIGHT"><div align="center"><font size="1"><strong>CHECK 
          NO. </strong></font></div></td>
      <td width="15%" class="thinborderBOTTOMRIGHT"><div align="center"><font size="1"><strong>OR 
          NO. </strong></font></div></td>
      <td width="10%" class="thinborderBOTTOMRIGHT"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <%if(!WI.fillTextValue("removeStud").equals("1")){%>
      <td width="10%" class="thinborderBOTTOMRIGHT"><div align="center"><font size="1"><strong>PAYMENT 
          DATE</strong></font></div></td>
      <%}%>
      <td width="10%" class="thinborderBOTTOM"><div align="center"><font size="1"><strong>CHECK 
          STATUS </strong></font></div></td>
    </tr>
    <% 
	String strName = null;
 	for(int iCount = 0; iCount <= iMaxStudPerPage; iLoop += 13,++iCount){
  		if (iCount >= iMaxStudPerPage || iLoop >= vRetResult.size()){
			if(iLoop >= vRetResult.size())
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;			
		 }
		if(vRetResult.elementAt(iLoop+1) == null)
			strName = (String)vRetResult.elementAt(iLoop+11);
		else	
			strName = WI.formatName((String)vRetResult.elementAt(iLoop+1),(String)vRetResult.elementAt(iLoop+2),
		  							(String)vRetResult.elementAt(iLoop+3),4);
		if(strName == null)
			strName = "&nbsp;";
    %>
    <tr> 
      <td class="thinborderBOTTOMRIGHT" height="25"><div align="center"><%=(iLoop+13)/13%></div></td>
      <td class="thinborderBOTTOMRIGHT"><div align="left"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(iLoop), "&nbsp;")%></font></div></td>
      <td class="thinborderBOTTOMRIGHT"><div align="left"><font size="1"><%=strName%></font></div></td>
      <td class="thinborderBOTTOMRIGHT"><div align="left"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+4),"&nbsp;")%></font></div></td>
      <td class="thinborderBOTTOMRIGHT"><div align="left"><font size="1"><%=(String)vRetResult.elementAt(iLoop+5)%></font></div></td>
      <td class="thinborderBOTTOMRIGHT"><div align="left"><font size="1"><%=(String)vRetResult.elementAt(iLoop+6)%></font></div></td>      
      <td class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+7)),true)%>&nbsp;</font><font size="1"> </font></div></td>      
	  <%if(!WI.fillTextValue("removeStud").equals("1")){%>
      <td class="thinborderBOTTOMRIGHT"><div align="left"><font size="1"><%=(String)vRetResult.elementAt(iLoop+8)+WI.getStrValue((String)vRetResult.elementAt(iLoop+9)," / ","","")%></font></div></td>
      <%}%>
	  <td class="thinborderBOTTOM"><div align="left"><font size="1"> 
          <%if(((String)vRetResult.elementAt(iLoop+10)) == null){%>
          For Clearing 
          <%}else{%>
          <%=astrChkStat[Integer.parseInt((String)vRetResult.elementAt(iLoop+10))]%> 
          <%}%>
          </font></div></td>
    </tr>
    <%}if (iLoop >= vRetResult.size()){%>
    <tr> 
      <td class="thinborderNONE" colspan="9" ><div align="center"> *****************NOTHING 
          FOLLOWS *******************</div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td class="thinborderNONE" colspan="9" ><div align="center"> ************** 
          CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}%>
  </table>
  <%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
	}%>
</form>
<script language="JavaScript">
	window.print();
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
