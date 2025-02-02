<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = false;
	if(WI.fillTextValue("my_home").compareTo("1") == 0 ){
		bolMyHome = true;
	}
	String strSchCode = 
			WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
			
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
a{
	text-decoration:none;
}

</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">


function ReloadPage(){
	this.SubmitOnce("form_");
}

function UpdateMemoIndex(){
	if (document.form_.memo_sent_index) 
		document.form_.memo_sent_index.selectedIndex = 0;
	this.SubmitOnce("form_");
}

function RemoveUser(strStrUserIndex){
	document.form_.info_index.value=strStrUserIndex;
	document.form_.page_action.value="10";
	this.SubmitOnce("form_");
}


</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-MEMO Management-Circulate memo","circular_memo.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
												"HR Management","MEMO MANAGEMENT",request.getRemoteAddr(),
												"circular_memo.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home"," ../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vDates = new Vector();

int iAction =  Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));
String strPrepareToEdit =  WI.fillTextValue("prepareToEdit");
hr.HRMemoManagement  mt = new hr.HRMemoManagement();

if (WI.fillTextValue("memo_index").length() > 0){
	java.sql.ResultSet rs = dbOP.executeQuery("select memo_sent_index, memo_sent" + 
											 " from hr_memo_sent " + 
											 " where memo_index= " + WI.fillTextValue("memo_index"));
	while (rs.next()){
		vDates.addElement(rs.getString(1));
		vDates.addElement(WI.formatDate(rs.getDate(2),10));
	}
	rs.close();
}



if (iAction == 10){
	if (mt.operateOnMemo(dbOP, request,10) != null){
		strErrMsg= " Personnel Memo removed successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}else if ( iAction == 1){
	if (mt.operateOnMemo(dbOP, request,1) != null){
		strErrMsg= " Required Personnel recorded successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}

if (WI.fillTextValue("view_all").equals("1")){
//	vRetResult = mt.operateOnMemo(dbOP, request,6);
//	if (vRetResult == null) 
//		strErrMsg = mt.getErrMsg();
}else{
//	vRetResult = mt.operateOnMemo(dbOP, request,4);
}

if (WI.fillTextValue("memo_index").length() > 0 && 
	WI.fillTextValue("memo_sent_index").length() > 0) {
		
		vRetResult = mt.operateOnMemo(dbOP, request, 4);
}
%>
<body bgcolor="#663300"  class="bgDynamic">
<form action="./circular_memo.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: SET MANDATORY TRAINING FOR PERSONNEL ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="17%" height="30">TYPE OF TRAINING </td>
 	  <td width="79%" height="30">
        <select name="memo_type_index" onChange="ReloadPage()">
          <option value="">Select Training Type</option>
          <%=dbOP.loadCombo("memo_type_index","memo_type"," FROM hr_preload_memo_type order by memo_type",WI.fillTextValue("memo_type_index"),false)%>
        </select><font size="1">(optional, filter only)</font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="4%">&nbsp;</td>
      <td width="17%" height="30" valign="bottom">MEMO  NAME </td>
      <td width="79%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="23" colspan="2"><strong>
        <select name="memo_index" onChange="UpdateMemoIndex()" >
          <option value="">Select Memo</option>
          <%=dbOP.loadCombo("memo_index","memo_name",
	  				" FROM hr_memo_details where is_valid = 1 and is_del = 0 " + 
					WI.getStrValue(request.getParameter("memo_type_index"),
					"and  memo_type_index = ","","") + 
					" order by memo_name",WI.fillTextValue("memo_index"),false)%>
        </select>
      </strong></td>
    </tr>
<% if (WI.fillTextValue("memo_index").length() > 0) {%> 
    <tr>
      <td>&nbsp;</td>
      <td height="23" colspan="2">Date of Memo : 
        <select name="memo_sent_index" onChange="ReloadPage()">
 	    <option value="">Select Date of Memo</option>
		<% for (int i = 0; i < vDates.size();i+=2){
			if (WI.fillTextValue("memo_sent_index").equals((String)vDates.elementAt(i))){
		%> 
		<option value="<%=(String)vDates.elementAt(i)%>" selected>
							<%=(String)vDates.elementAt(i+1)%></option>
		<%}else{%> 
		<option value="<%=(String)vDates.elementAt(i)%>">
							<%=(String)vDates.elementAt(i+1)%></option>		
		<%} // end if else
		} // end for loop%> 		
		</select> 
		</td>
    </tr>
<%}%> 
  </table>

<% if (WI.fillTextValue("memo_sent_index").length() > 0) {%>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="23"><hr size="1" noshade></td>
    </tr>
    <% if (vRetResult !=null && vRetResult.size() > 0) {%>
    <tr>
      <td height="23"><%=(String)vRetResult.elementAt(0)%></td>
    </tr>
    <tr>
      <td height="23"><hr size="1" noshade></td>
    </tr>
	<%}%>
  </table>
  
<% if (vRetResult !=null && vRetResult.size() >1) {%>  
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" 
  		bgcolor="#FFFFFF" class="thinborder">
  <tr>
     <td height="23" colspan="4" bgcolor="#F3F5E9" class="thinborder">
	 			<strong>Recipients : </strong>
	  </td>
  </tr>
<% 	
	int iCtr2 = (vRetResult.size() - 1)/4; // number of employees
	iCtr2 = iCtr2 / 2; // num employees  div no. of colums.. 
	
	// 46 /2 %2 =   23 % 2 = 1
	if (((vRetResult.size() - 1)/4) % 2 != 0) 
		iCtr2+=2;
	else
		iCtr2+=1;


	for (int i = 1,iCtr1 =1; i < vRetResult.size();){%>
    <tr>
      <td width="41%" height="23" class="thinborder">&nbsp;&nbsp; <%=iCtr1 + ") " + (String)vRetResult.elementAt(i) + " " + 
								(String)vRetResult.elementAt(i+1)%> </td>
      <td width="9%" class="thinborderBOTTOM">&nbsp;
	  <% if (!((String)vRetResult.elementAt(i+3)).equals("1")) {%> 
	  	<a href="javascript:RemoveUser('<%=(String)vRetResult.elementAt(i+2)%>')">REMOVE</a>
	  <%}%> 	
		
	  </td>
      <% i += 4;iCtr1++;
	 	if (i < vRetResult.size())
			strTemp = "&nbsp;&nbsp; "+ iCtr2 + ") " + (String)vRetResult.elementAt(i) + " " + 
									(String)vRetResult.elementAt(i+1);
		else
			strTemp = "";
		
	 %>
      <td width="41%" height="23" class="thinborder">&nbsp;<%=strTemp%></td>
      <td width="9%" class="thinborderBOTTOM">&nbsp;
	  <% if (i < vRetResult.size() && !((String)vRetResult.elementAt(i+3)).equals("1")){%> 
	  	<a href="javascript:RemoveUser('<%=(String)vRetResult.elementAt(i+2)%>')">REMOVE</a>
	  <%}%>
	  </td>
      <% i += 4; iCtr2++; %>
    </tr>
    <%}
	}
	%>
  </table>
  <%}%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action"> 
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

