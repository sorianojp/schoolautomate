<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function OpenSearchPO(){
	document.form_.print_pg.value = "";
	var pgLoc = "../canvassing/canvassing_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PrintPg(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}
function PageLoad(){
	document.form_.req_no.focus();
}
function CheckAll()
{
	document.form_.print_pg.value = "";
	var iMaxDisp = document.form_.max_display.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 0 ; i < eval(iMaxDisp);++i)
			eval('document.form_.req_item_index_'+i+'.checked=true');
	}
	else
		for (var i = 0 ; i < eval(iMaxDisp);++i)
			eval('document.form_.req_item_index_'+i+'.checked=false');
		
}
</script>
<%
	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="./request_requotation_print.jsp"/>
	<%return;}
	
    //authenticate user access level
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-QUOTATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
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
								"PURCHASING-QUOTATION","request_requotation.jsp");
	Quotation QTN = new Quotation();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vReqItemsPO = null;	
	String strErrMsg = null;
	String strTemp1 = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};
	String strInfoIndex = WI.fillTextValue("info_index");
	int iLoop = 0;
	int iCount = 0;
	int iItems = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request);
		if(vReqInfo == null)
			strErrMsg = QTN.getErrMsg();
		else{
			strInfoIndex = (String)vReqInfo.elementAt(0);//requisition_index
			vRetResult = QTN.getRequestItems(dbOP,request,strInfoIndex);
			if(vRetResult == null)
				strErrMsg = QTN.getErrMsg();			
		}				
	}
%>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<form name="form_" method="post" action="request_requotation.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          QUOTATION - PRINT FOR REQUOTATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Canvass No. :</td>
      <td width="36%"><%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp1 = WI.fillTextValue("req_no");
	    }else{
	  		strTemp1 = "";
        }%>
          <input type="text" name="req_no" class="textbox" value="<%=strTemp1%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="41%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search canvass no.</font></td>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"> </a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%if(vReqInfo != null && vReqInfo.size() > 2){%>
    <tr>
      <td height="25">  
      <td>Canvass No. :<strong><%=vReqInfo.elementAt(1)%></strong></td>
      <td><div align="center">Canvass Date : <strong><%=vReqInfo.elementAt(2)%></strong> </div></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%}%>
  </table>
  <%if(vReqInfo != null && vReqInfo.size() > 2){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR  CANVASS NO : <%=vReqInfo.elementAt(1)%></strong></div></td>
    </tr>
    <tr>
      <td height="25" width="4%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=vReqInfo.elementAt(3)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"><strong><%=vReqInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(5))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=vReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(7))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(9)) == null){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2"><a href="request_requotation2.jsp?proceedClicked=1&req_no=<%=WI.fillTextValue("req_no")%>">Click here to go to other format</a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>		
  </table>
  <%if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="10" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUISITION ITEM(S)</strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%" height="26" align="center" class="thinborder"><font size="1"><strong>QTY</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>UNIT</strong></font></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>ITEM 
          / PARTICULARS / DESCRIPTION </strong></font></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">BRAND</font></strong></td>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>SUPPLIER 
          CODE </strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>PRICE 
          QUOTED</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>DISCOUNT</strong></font></td>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>UNIT 
          PRICE</strong></font></td>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>TOTAL 
          AMOUNT</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>SELECT<br>
        ALL
            <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
        </strong></font></td>
    </tr>
    <%//System.out.println("size " + vRetResult.size());
	for(iLoop = 0,iCount = 0;iLoop < vRetResult.size();iLoop+=11,++iCount,++iItems){%>
    <tr> 
      <td height="25" align="center" class="thinborder"><%=vRetResult.elementAt(iLoop+1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(iLoop+3)%> / <%=vRetResult.elementAt(iLoop+4)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(iLoop+10),"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=vRetResult.elementAt(iLoop+5)%> 
        <%
			strTemp1 = "";
			strTemp2 = "";
			strTemp3 = "";
			strErrMsg = "";			
			for(; (iLoop + 11) < vRetResult.size() ;){
			//System.out.println("iLoop " +(String)vRetResult.elementAt(iLoop));
			//System.out.println("iLoop11 " +(String)vRetResult.elementAt(iLoop + 11));
			 if(!(((String)vRetResult.elementAt(iLoop)).equals((String)vRetResult.elementAt(iLoop + 11))))
					break;			 
			 strErrMsg += (String)vRetResult.elementAt(iLoop+6)+ "<br>";
			 strTemp1 += (String)vRetResult.elementAt(iLoop+7)+ "<br>";
			 strTemp2 += (String)vRetResult.elementAt(iLoop+8)+ "<br>";
			 strTemp3 += (String)vRetResult.elementAt(iLoop+9)+ "<br>";%>
        <br>
        <%=(String)vRetResult.elementAt(iLoop + 11 + 5)%> 
        <%iLoop += 11;}%>        </td>
      <td align="right" class="thinborder"><%=strErrMsg + (String)vRetResult.elementAt(iLoop+6)%></td>
      <td align="right" class="thinborder"> <%=strTemp1 + (String)vRetResult.elementAt(iLoop+7)%></td>
      <td align="right" class="thinborder"><%=strTemp2 + (String)vRetResult.elementAt(iLoop+8)%></td>
      <td align="right" class="thinborder"><%=strTemp3 + (String)vRetResult.elementAt(iLoop+9)%></td>
      <td align="center" class="thinborder">        <input type="checkbox" name="req_item_index_<%=iCount%>" value="<%=vRetResult.elementAt(iLoop)%>">        </td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="10" class="thinborder"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount%> 
        <input type="hidden" name="num_of_items" value="<%=iCount%>">
        </strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%">
    <tr>
      <td>&nbsp;</td>
	</tr>
  </table>
  <%}if((vReqItemsPO != null && vReqItemsPO.size() > 3) || (vRetResult != null && vRetResult.size() > 3)){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="center"> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"> </a> <font size="1">click to print this details</font></div></td>
    </tr>
  </table>
  <%}}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="max_display" value ="<%=iItems%>">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="delete_cost" >
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
