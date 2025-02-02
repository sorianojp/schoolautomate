<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";	
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.CheckPayment"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2    = null;
	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="check_payment_print.jsp"/>
	<%}
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Check Payment Management",
								"check_payment_view_search.jsp");
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
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
															"check_payment_view_search.jsp");
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
	}//end of authenticaion code.

	Vector vRetResult = null;
	CheckPayment CP = new CheckPayment();
	int iSearch = 0;
	int iDefault = 0;
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName = {"Check No.","OR No.","Bank","Check Status","ID No.","Lastname","Firstname","Exam Schedule"};
	String[] astrSortByVal = {"CHECK_NO","OR_NUMBER","CHECK_FR_BANK_INDEX","CHK_STATUS","ID_NUMBER","LNAME","FNAME","FA_STUD_PAYMENT.PMT_SCH_INDEX"};
	String[] astrChkStat = {"For Clearing","Cleared","Bounced"};
	
	if(WI.fillTextValue("proceedClicked").equals("1")){		
		vRetResult = CP.searchList(dbOP,request);
		if(vRetResult == null)
			strErrMsg = CP.getErrMsg();
		else
			iSearch = CP.getSearchCount();		
	}	
%>
<form name="form_" method="post" action="./check_payment_view_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          VIEW/SEARCH CHECK PAYMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">School Year / Term :</td>
      <td width="80%"> <% strTemp = WI.fillTextValue("sy_from");
			if(strTemp.length() ==0)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); 
			%> <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
			onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
			onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%  strTemp = WI.fillTextValue("sy_to");
			if(strTemp.length() ==0)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); 
			%> <input name="sy_to" type="text" size="4" maxlength="4" 
			value="<%=strTemp%>" class="textbox"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        / 
        <select name="semester">
          <% strTemp = WI.fillTextValue("semester");
			if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
				strTemp = (String)request.getSession(false).getAttribute("cur_sem");
			if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected=>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> 
		<font style="font-weight:bold; font-size:11px; color:#0000FF">
			<input type="checkbox" name="ignore_syterm" value="selected" <%=WI.fillTextValue("ignore_syterm")%>> Ignore SY-Term
		</font>
		
		</td>
    </tr>
	<tr>
      <td height="25">&nbsp;</td>
      <td height="25">OR No. :</td>
      <td height="25"><select name="or_no_select">
          <%=CP.constructGenericDropList(WI.fillTextValue("or_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="or_no" class="textbox" value="<%=WI.fillTextValue("or_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%" height="25">Check No. : </td>
      <td height="25"> <select name="check_no_select">
          <%=CP.constructGenericDropList(WI.fillTextValue("check_no_select"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
        <input type="text" name="check_no" class="textbox" value="<%=WI.fillTextValue("check_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Bank :</td>
      <td height="25"> <select name="bank">
          <option value="">All</option>
          <%=dbOP.loadCombo("BANK_INDEX","BANK_CODE"," from FA_BANK_LIST where IS_DEL=0 order by BANK_CODE asc", 
		  WI.fillTextValue("bank"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Date of Payment :</td>
      <td height="25">From: 
        <input name="date_fr" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("date_fr" )%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To: 
        <input name="date_to" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("date_to")%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Check Status :</td>
      <td height="25"> <select name="check_status">
          <option value="">All</option>
          <%if(WI.fillTextValue("check_status").equals("0")){%>
          <option value="0" selected>For Clearing</option>
          <option value="1">Cleared</option>
          <option value="2">Bounced</option>
          <%}else if(WI.fillTextValue("check_status").equals("1")){%>
          <option value="0">For Clearing</option>
          <option value="1" selected>Cleared</option>
          <option value="2">Bounced</option>
          <%}else if(WI.fillTextValue("check_status").equals("2")){%>
          <option value="0">For Clearing</option>
          <option value="1">Cleared</option>
          <option value="2" selected>Bounced</option>
          <%}else{%>
          <option value="0">For Clearing</option>
          <option value="1">Cleared</option>
          <option value="2">Bounced</option>
          <%}%>
        </select></td>
    </tr>
	<tr>
      <td height="25">&nbsp;</td>
      <td height="25">Exam Schedule:</td>
      <td height="25">
	  <select name="exam_sched">
          <option value="">All</option>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where IS_DEL=0", 
		  WI.fillTextValue("exam_sched"), false)%>
	  </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student ID No. :</td>
      <td height="25"> <select name="stud_id_select">
          <%=CP.constructGenericDropList(WI.fillTextValue("stud_id_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="stud_id" class="textbox" value="<%=WI.fillTextValue("stud_id")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student Last Name:</td>
      <td><select name="stud_lname_select">
          <%=CP.constructGenericDropList(WI.fillTextValue("stud_lname_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="stud_lname" class="textbox" value="<%=WI.fillTextValue("stud_lname")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student First Name:</td>
      <td><select name="stud_fname_select">
          <%=CP.constructGenericDropList(WI.fillTextValue("stud_fname_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="stud_fname" class="textbox" value="<%=WI.fillTextValue("stud_fname")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td colspan="5"><strong>Sort</strong></td>
    </tr>
    <tr> 
      <td height="5">&nbsp;</td>
      <td width="19%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=CP.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="19%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=CP.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="19%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=CP.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="19%"><select name="sort_by4">
          <option value="">N/A</option>
          <%=CP.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="19%"><select name="sort_by5">
          <option value="">N/A</option>
          <%=CP.constructSortByDropList(WI.fillTextValue("sort_by5"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by5_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by5_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a> 
      </td>
    </tr>    
  </table>
  <%if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr> 
      <td height="28" colspan="2"><div align="right">Number of Students Per Page: 
          <select name="num_stud_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
	  <a href="javascript:PrintPage();">
	  <img src="../../../images/print.gif" border="0"></a>
	  <font size="1"> 
          click to print list</font></div></td>
    </tr>
  	  <tr> 
      <td width="51%" height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=CP.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/CP.defSearchSize;		
		if(iSearch % CP.defSearchSize > 0) ++iPageCount;		
		if(iPageCount >= 1)
		{%>
		&nbsp;</td>
		
      <td width="49%"> <div align="right">Jump to page: 
          <select name="jumpto" onChange="ProceedClicked();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
				}
			}
		%>
          </select>
          <%}%>
        </div></td>
    </tr>	   
	  <tr>
	  	  <td height="25" bgcolor="#B9B292" colspan="2"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF CHECK PAYMENTS</strong></font></div></td>
	  </tr>
	  
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%"  height="25"><div align="center"><font size="1"><strong> 
          NO. </strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>PAYEE NAME </strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>BANK</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>CHECK NO.</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>OR NO.</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>PAYMENT DATE</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>CHECK STATUS</strong></font></div></td>
    </tr>
    <% int iLoop = 0;
	String strName = null;
	for(;iLoop < vRetResult.size();iLoop+=13){
		if(vRetResult.elementAt(iLoop+1) == null)
			strName = (String)vRetResult.elementAt(iLoop+11);
		else	
			strName = WI.formatName((String)vRetResult.elementAt(iLoop+1),(String)vRetResult.elementAt(iLoop+2),
		  							(String)vRetResult.elementAt(iLoop+3),4);
		if(strName == null)
			strName = "&nbsp;";
	%>
    <tr> 
      <td width="5%" height="25"><div align="center"><font size="1"><%=(iLoop+13)/13%></font></div></td>
      <td width="5%"><div align="left"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(iLoop), "&nbsp;")%></font></div></td>
      <td width="5%"><div align="left"><font size="1"><%=strName%></font></div></td>
      <td width="5%"><div align="left"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+4),"&nbsp;")%></font></div></td>
      <td width="5%"><div align="left"><font size="1"><%=(String)vRetResult.elementAt(iLoop+5)%></font></div></td>
      <td width="5%"><div align="left"><font size="1"><%=(String)vRetResult.elementAt(iLoop+6)%></font></div></td>
      <td width="5%"><div align="right"><font size="1"><%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(iLoop+7)),true)%>&nbsp;</font></div></td>
      <td width="5%"><div align="left"><font size="1"><%=(String)vRetResult.elementAt(iLoop+8)+WI.getStrValue((String)vRetResult.elementAt(iLoop+9)," / ","","")%></font></div></td>
      <td width="5%"><div align="left"><font size="1"> 
          <%if(((String)vRetResult.elementAt(iLoop+10)) == null){%>
          For Clearing
          <%}else{%>
          <%=astrChkStat[Integer.parseInt((String)vRetResult.elementAt(iLoop+10))]%> 
          <%}%>
          </font></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="strIndex" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
