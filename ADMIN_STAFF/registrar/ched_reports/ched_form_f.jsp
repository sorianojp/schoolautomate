<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDFormBC,chedReport.CHEDInstProfile"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	if (WI.fillTextValue("print_page").equals("1")){
%>
	<jsp:forward page="./ched_form_b_c_print.jsp?show_details=1" />
<%
	return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED E-FORM B/C</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CHED REPORTS-CHED FORM B C","ched_form_b_c.jsp");
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


Vector vRetResult = null;
Vector vRetTransferrees  = null;
CHEDInstProfile cip = new CHEDInstProfile();
int i =0;

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (WI.fillTextValue("sy_from").length() == 4){  
	vRetResult = cip.viewAgeDistribution(dbOP,request);
	vRetTransferrees = cip.viewNoOfTransferees(dbOP,request);
			
	if (vRetResult == null && cip.getErrMsg() != null) {
		strErrMsg = cip.getErrMsg();
	}
	
	if (vRetTransferrees == null &&  cip.getErrMsg() != null){
		strErrMsg= cip.getErrMsg();
	}
}


%>
<body>
<form name="form_" action="./ched_form_f.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Arial, Helvetica, sans-serif"><strong>CHED FORM F DATA </strong> </font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <!--DWLayoutTable-->
    <tr> 
      <td width="123" height="25" class="body_font">&nbsp;Academic Year</td>
      <td width="848"> <% 
	strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length()  < 4){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUP="DisplaySYTo('form_','sy_from','sy_to')">
        to 
     <% 
		strTemp = WI.fillTextValue("sy_to");
	
	if (strTemp.length() < 4 ){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
        &nbsp;&nbsp; <input type="image" src="../../../images/form_proceed.gif" border="0"> 
      </td>
    </tr>
    <tr>
      <td height="25" class="body_font"><!--DWLayoutEmptyCell-->&nbsp;</td>
      <td><!--DWLayoutEmptyCell-->&nbsp;</td>
    </tr>
  </table>
<% if ( vRetTransferrees != null && vRetTransferrees.size() > 0) {%>
  <table width="60%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBE8DC"> 
      <td height="25" colspan="4" class="thinborder"><div align="center"><strong>TRANFEREE 
          DATA </strong></div></td>
    </tr>
    <tr> 
      <td width="47%"  height="37" rowspan="2" class="thinborder"><div align="center"><strong>Program 
          Level <br>
          </strong></div></td>
      <td colspan="3" class="thinborder"><div align="center">COMING FROM</div></td>
    </tr>
    <tr> 
      <td width="27%" class="thinborder"><div align="center">PUBLIC</div></td>
      <td width="26%" class="thinborder">PRIVATE </td>
      <td width="26%" class="thinborder"><div align="center">SEMI PUBLIC /PRIVATE</div></td>
    </tr>
<%
	String strCurrProgLevel = null;
	int iTotalTransferee = 0;
for (i= 0 ; i < vRetTransferrees.size() ;) {
	strCurrProgLevel = (String)vRetTransferrees.elementAt(i);
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp; <%=(String)vRetTransferrees.elementAt(i+1)%></td>
	  <% if (strCurrProgLevel.equals(WI.getStrValue((String)vRetTransferrees.elementAt(i),"0")) 
	  			&& WI.getStrValue((String)vRetTransferrees.elementAt(i+2),"").equals("0")) {
		 
		 	strTemp = (String)vRetTransferrees.elementAt(i+3);
			iTotalTransferee = Integer.parseInt(strTemp);
			i+=4;
		}
		 else{
		 	strTemp = "0";
		 }
	  %>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	  <% if ( i <vRetTransferrees.size() && 
	  		strCurrProgLevel.equals(WI.getStrValue((String)vRetTransferrees.elementAt(i),"")) 
	  			&& WI.getStrValue((String)vRetTransferrees.elementAt(i+2),"").equals("1")) {
		 
		 	strTemp = (String)vRetTransferrees.elementAt(i+3);
			iTotalTransferee = Integer.parseInt(strTemp);
			i+=4;
		}
		 else{
		 	strTemp = "0";
		 }
	  %>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
	  <% if ( i <vRetTransferrees.size() && 
	  			strCurrProgLevel.equals(WI.getStrValue((String)vRetTransferrees.elementAt(i),"0")) 
	  			&& WI.getStrValue((String)vRetTransferrees.elementAt(i+2),"").equals("2")) {
		 
		 	strTemp = (String)vRetTransferrees.elementAt(i+3);
			iTotalTransferee = Integer.parseInt(strTemp);
			i+=4;
		}
		 else{
		 	strTemp = "0";
		 }
	  %>

      <td class="thinborder">&nbsp;<%=strTemp%></td>
    </tr>
<%}%>
  </table>
  <br>
<%} if (vRetResult != null) {%>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBE8DC"> 
      <td height="25" colspan="14" class="thinborder"><div align="center"> <strong>DISTRIBUTION 
          OF STUDENTS by AGE, PROGRAM LEVEL AND GENDER</strong></div></td>
    </tr>
    <tr> 
      <td width="12%"  height="37" rowspan="2" align="center" class="thinborder"><div align="center"><strong>Age</strong><strong><br>
          </strong></div></td>
      <td colspan="2" align="center" class="thinborder"><div align="center">Pre-baccalaureate</div></td>
      <td colspan="2" align="center" class="thinborder">Baccalaureate</td>
      <td colspan="2" align="center" class="thinborder">Post-baccalaureate </td>
      <td colspan="2" align="center" class="thinborder">Master's </td>
      <td colspan="2" align="center" class="thinborder">Doctorate </td>
      <td colspan="3" align="center" class="thinborder">Total </td>
    </tr>
    <tr> 
      <td width="7%" align="center" class="thinborder"><div align="center">Male</div></td>
      <td width="7%" align="center" class="thinborder">Female</td>
      <td width="6%" align="center" class="thinborder">Male<br></td>
      <td width="7%" align="center" class="thinborder">Female<br></td>
      <td width="6%" align="center" class="thinborder">Male<br></td>
      <td width="7%" align="center" class="thinborder">Female<br></td>
      <td width="6%" align="center" class="thinborder">Male<br></td>
      <td width="7%" align="center" class="thinborder">Female<br></td>
      <td width="7%" align="center" class="thinborder">Male<br></td>
      <td width="7%" align="center" class="thinborder">Female</td>
      <td width="7%" align="center" class="thinborder">Male<br> </td>
      <td width="7%" align="center" class="thinborder">Female <br></td>
      <td width="7%" align="center" class="thinborder">Both</td>
    </tr>
<% 
	int iAgeMTotal = 0;
	int iAgeFTotal = 0;

	Vector vTotals = (Vector) vRetResult.elementAt(0);
	boolean bolIncremented = false;
	
for (i = 1; i < vRetResult.size();) {	
	bolIncremented = false;
	
	
	iAgeMTotal = 0;
	iAgeFTotal = 0;
	
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <% if (   i < vRetResult.size() && //(String)vRetResult.elementAt(i) != null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("5")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("M"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=4;
			  bolIncremented = true;
		 }else{
		 	strTemp =  "0";
		 }
		 
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (   i < vRetResult.size() && //(String)vRetResult.elementAt(i) == null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("5")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("F"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=4;
			  bolIncremented = true;			  
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (   i < vRetResult.size() &&// (String)vRetResult.elementAt(i) == null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("4")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("M"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=4;
			  bolIncremented = true;			  
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (   i < vRetResult.size() && //(String)vRetResult.elementAt(i) == null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("4")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("F"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=4;
			  bolIncremented = true;			  
		 }else{
		 	strTemp =  "0";
		 }	 
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (   i < vRetResult.size() && //(String)vRetResult.elementAt(i) == null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("3")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("M"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=4;			  
			  bolIncremented = true;			  
		 }else{
		 	strTemp =  "0";
		 }
	 
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (   i < vRetResult.size() && //(String)vRetResult.elementAt(i) == null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("3")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("F"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=4;
			  bolIncremented = true;			  
		 }else{
		 	strTemp =  "0";
		 }	 
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (   i < vRetResult.size() && //(String)vRetResult.elementAt(i) == null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("2")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("M"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=4;
			  bolIncremented = true;			  
		 }else{
		 	strTemp =  "0";
		 }

	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (   i < vRetResult.size() && //(String)vRetResult.elementAt(i) == null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("2")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("F"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=4;
			  bolIncremented = true;			  
		 }else{
		 	strTemp =  "0";
		 }
	 
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% 	  
	  	if (   i < vRetResult.size() &&  //(String)vRetResult.elementAt(i) == null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("1")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("M"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=4;
			  bolIncremented = true;
		 }else{
		 	strTemp =  "0";
		 } 
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% 
	  if (i < vRetResult.size() && //(String)vRetResult.elementAt(i) == null && 
	  			((String)vRetResult.elementAt(i+1) != null && ((String)vRetResult.elementAt(i+1)).equals("1")) &&
	  		    ((String)vRetResult.elementAt(i+2) != null && ((String)vRetResult.elementAt(i+2)).equals("F"))){
			  
			  strTemp = (String)vRetResult.elementAt(i+3);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=4;
			  bolIncremented = true;			  
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td align="right" class="thinborder"><%=iAgeMTotal%>&nbsp;</td>
      <td align="right" class="thinborder"><%=iAgeFTotal%>&nbsp;</td>
      <td align="right" class="thinborder"><%=iAgeMTotal+iAgeFTotal%>&nbsp;</td>
    </tr>
  <%
  	if (!bolIncremented) {
		System.out.println( " Infinite loop : ched_form_f.jsp");
//		System.out.println("vRetResult : " + vRetResult);
		break;
	}
  } // end for loop
  
  	iAgeMTotal = 0;
	iAgeFTotal = 0;
	i = 0;
	if (vTotals != null && vTotals.size() > 0) {
  %>	
    <tr>
      <td height="25" class="thinborder"><div align="center"><strong>TOTALS</strong></div></td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("5")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("M"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
	  <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("5")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("F"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
	  <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("4")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("M"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("4")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("F"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("3")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("M"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("3")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("F"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("2")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("M"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("2")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("F"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("1")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("M"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeMTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <% if (((String)vTotals.elementAt(i) != null && ((String)vTotals.elementAt(i)).equals("1")) &&
	  		    ((String)vTotals.elementAt(i+1) != null && ((String)vTotals.elementAt(i+1)).equals("F"))){
			  
			  strTemp = (String)vTotals.elementAt(i+2);
			  iAgeFTotal += Integer.parseInt(strTemp);
			  i+=3;
		 }else{
		 	strTemp =  "0";
		 }
	  %>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td align="right" class="thinborder"><%=iAgeMTotal%>&nbsp;</td>
      <td align="right" class="thinborder"><%=iAgeFTotal%>&nbsp;</td>
      <td align="right" class="thinborder"><%=iAgeMTotal+iAgeFTotal%>&nbsp;</td>
    </tr>
  </table>
<%} // if vTotals != null
} // if (vRetResult != null) %>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
